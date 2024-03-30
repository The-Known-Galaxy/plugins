--!strict
--[=[
    @class SubModuleManager
    
    Manages [PluginSubModule] instances.

    Intended usage:
    ```lua
    local SubModuleManager = require(script.path.to.SubModuleManager)
    local manager = SubModuleManager.new()

    local possibleSubModuleInstances = manager:CollectModules(script.path.to.SubModuleDirectory)
    manager:LoadModules(possibleSubModuleInstances):andThen(function(results)
        -- whatever custom code that is needed with successful and unsuccessful module loads
        -- ...
        local validModules
        manager:RunLifeCycles(validModules)
    end)

    -- later, when plugin needs to switch off
    manager:UnloadAllModules()
    ```
]=]

local Promise = require(script.Parent.Parent.Parent.Libraries.Promise)

local Logger = require(script.Parent.Logger)
local Janitor = require(script.Parent.Parent.Parent.Libraries.Janitor)
local PluginFacade = require(script.Parent.Parent.PluginFacade)
local PluginSubModule = require(script.Parent.PluginSubModule)

type SubModuleManagerImpl = {
	__index: SubModuleManagerImpl,
	new: () -> SubModuleManager,
	ValidPluginSubModule: (instance: Instance) -> boolean,
	CollectModules: (self: SubModuleManager, root: Instance) -> ModuleScriptCollection,
	LoadModules: (self: SubModuleManager, moduleCollection: ModuleScriptCollection) -> any,
	RunLifeCycles: (self: SubModuleManager, pluginSubModules: SubModuleCollection, toolbarName: string) -> (),
	UnloadAllModules: (self: SubModuleManager) -> (),
	InvokeLifeCycleHookIfExists: (self: SubModuleManager, module: ManagedModule, key: string) -> (),
	ToggleModuleActivation: (self: SubModuleManager, managedModule: ManagedModule, forcedState: boolean?) -> (),
}
type SubModuleManagerProperties = {
	_janitor: typeof(Janitor.new()),
	ManagedModules: { [string]: ManagedModule },
	ManagingModules: boolean,
}
export type SubModuleManager = typeof(setmetatable({} :: SubModuleManagerProperties, {} :: SubModuleManagerImpl))

export type ModuleScriptCollection = { ModuleScript }
export type SubModuleCollection = { PluginSubModule.PluginSubModule }

export type LoadResult = {
	Ok: boolean,
	ModuleScript: ModuleScript,
}
export type LoadSuccess = LoadResult & {
	Module: PluginSubModule.PluginSubModule,
}
export type LoadFailure = LoadResult & {
	FailureReason: string,
}

export type ManagedModule = {
	Module: PluginSubModule.PluginSubModule,
	ShouldLoad: boolean,
	NotLoadingReason: string?,
	ToolbarButton: PluginToolbarButton,
}

local SUB_MODULE_SUFFIX = "module"
local SUFFIX_SEPARATOR = "."

local SubModuleManager: SubModuleManagerImpl = {} :: SubModuleManagerImpl
SubModuleManager.__index = SubModuleManager

function SubModuleManager.new(): SubModuleManager
	local self = setmetatable({
		_janitor = Janitor.new(),
		ManagedModules = {},
		ManagingModules = false,
	}, SubModuleManager)

	return self
end

--[=[
    Validates whether an instance is likely a valid [PluginSubModule].
    Does not `require` it if it is one though.
]=]
function SubModuleManager.ValidPluginSubModule(instance: Instance): boolean
	return instance:IsA("ModuleScript") and instance.Name:split(SUFFIX_SEPARATOR)[2] == SUB_MODULE_SUFFIX
end

--[=[
    Finds all [ModuleScript]s that could potentially return a [PluginSubModule] and requires them.
    A module identifiable by the manager is one where the name has `.module` at the end of it.
]=]
function SubModuleManager:CollectModules(root: Instance): ModuleScriptCollection
	local modules: ModuleScriptCollection = {}

	for _, descendant in root:GetDescendants() do
		if SubModuleManager.ValidPluginSubModule(descendant) then
			table.insert(modules, descendant :: ModuleScript)
		end
	end

	return modules
end

--[=[
    Loads all the module scripts inside the collection, validating them.
    Uses [Promises](https://eryn.io/roblox-lua-promise/) internally.
]=]
function SubModuleManager:LoadModules(moduleCollection: ModuleScriptCollection): any
	local loadPromises = {}

	local currentModuleScript: ModuleScript

	local function wrapInSuccess(subModule: PluginSubModule.PluginSubModule): LoadSuccess
		return {
			Ok = true,
			ModuleScript = currentModuleScript,
			Module = subModule,
		}
	end

	local function wrapInFailure(reason: string): LoadFailure
		return {
			Ok = false,
			ModuleScript = currentModuleScript,
			FailureReason = reason,
		}
	end

	for _, module in moduleCollection do
		currentModuleScript = module

		local loadPromise = Promise.new(function(resolve, reject, _onCancel)
			-- attempting to run the module
			local ok, result: string | PluginSubModule.PluginSubModule = pcall(require, module)
			if ok then
				if type(result) == "table" then
					if getmetatable(result) == PluginSubModule then
						resolve(wrapInSuccess(result))
					else
						reject(wrapInFailure("Not a a valid PluginSubModule."))
					end
				else
					reject(wrapInFailure("Return result not a table."))
				end
			else
				reject(wrapInFailure(`Module errored on loading. Error:\n> {result}`))
			end
		end):andThen(function(success: LoadSuccess)
			return Promise.resolve(success)
		end, function(failure: LoadFailure)
			Logger.Warn(
				`[{failure.ModuleScript.Name:split(SUFFIX_SEPARATOR)[1]}] load failure: {failure.FailureReason}`
			)
			return Promise.resolve(failure)
		end)

		table.insert(loadPromises, loadPromise)
	end

	return Promise.all(loadPromises)
end

--[=[
    Runs all life cycle hooks on plugin sub-modules.
    Creates activation buttons for all submodules too, in a toolbar with the given name.
]=]
function SubModuleManager:RunLifeCycles(pluginSubModules: SubModuleCollection, toolbarName: string)
	if self.ManagingModules then
		Logger.Warn("Cannot run any more life cycles on new modules. Already managing some.")
		return
	end
	self.ManagingModules = true

	-- if a toolbar with the given name already exists, then it doesn't create it, just fetches it like a GET request
	local toolbar = PluginFacade:CreateToolbar(toolbarName)

	-- pre-loading and setting up modules
	for _, module in pluginSubModules do
		local shouldLoad, reason = module._executors.PreLoad()

		-- creating a button for it
		local moduleId = tostring(module.UID)
		local submoduleButton =
			PluginFacade:CreateButton(toolbar, moduleId, module.Tooltip, module.ButtonIcon, module.DisplayName)

		-- remembering the module's meta data for management
		self.ManagedModules[moduleId] = {
			Module = module,
			ShouldLoad = shouldLoad,
			NotLoadingReason = reason,
			ToolbarButton = submoduleButton,
		}

		self._janitor:Add(
			submoduleButton.Click:Connect(function()
				self:ToggleModuleActivation(self.ManagedModules[moduleId])
			end),
			nil,
			`Button{module.UID}Click`
		)

		-- running post loading hooks
		if shouldLoad then
			self:InvokeLifeCycleHookIfExists(self.ManagedModules[moduleId], "Postload")
		end
	end
end

--[=[
    Declares all managed modules that this manager knows about as unloaded, and calls necessary life cycle hooks on them.
    This should be done only once.
]=]
function SubModuleManager:UnloadAllModules()
	if not self.ManagingModules then
		Logger.Warn("Cannot unload any modules. No modules are being managed.")
		return
	end

	for moduleId, managedModule in self.ManagedModules do
		if managedModule.ShouldLoad then
			-- forcing a deactivation first
			self:ToggleModuleActivation(managedModule, false)

			-- then unloading
			self:InvokeLifeCycleHookIfExists(managedModule, "PreUnload")
		end

		-- removing button click connection
		-- not running Janitor:Cleanup() since other events might be connected from elsewhere in the module that we don't want to cleanup
		self._janitor:Remove(`Button{moduleId}Click`)
	end

	-- marking all managed modules for cleanup
	self.ManagedModules = {}
	self.ManagingModules = false
end

--[=[
    Invokes a given life cycle executor hook on a managed module.
]=]
function SubModuleManager:InvokeLifeCycleHookIfExists(managedModule: ManagedModule, executorName: string)
	local executors = managedModule.Module._executors

	if executors[executorName] ~= nil and type(executors[executorName]) == "function" then
		local ok, result = pcall(executors[executorName])

		-- warning when life cycle executor fails
		if not ok then
			Logger.Warn(`{managedModule.Module.DisplayName} running {executorName} errored:\n> {result}`)
		end
	end
end

--[=[
    Toggles a [PluginSubModule.Active] status whilst also validating if someone can, _and_ calls the necessary life cycle hooks.
    Optionally can also force a module's activation.
]=]
function SubModuleManager:ToggleModuleActivation(managedModule: ManagedModule, forcedState: boolean?)
	local module = managedModule.Module
	if not managedModule.ShouldLoad then
		Logger.Warn(`You cannot access [{module.DisplayName}]. Reason: {managedModule.NotLoadingReason}`)
		return
	end

	-- activate/deactivate module
	if forcedState ~= nil then
		if forcedState ~= module.Active then
			module.Active = forcedState
		else
			-- should not call any life cycle hooks or do extra things when the new state is the same as the old state
			return
		end
	else
		module.Active = not module.Active
	end

	self:InvokeLifeCycleHookIfExists(managedModule, if module.Active then "Activate" else "Deactivate")
	managedModule.ToolbarButton:SetActive(module.Active)
end

return SubModuleManager
