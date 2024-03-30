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
	new: (facade: PluginFacade.PluginFacade) -> SubModuleManager,
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
	PluginFacade: PluginFacade.PluginFacade,
	ManagedModules: { [string]: ManagedModule },
	ManagingModules: boolean,
}
export type SubModuleManager = typeof(setmetatable({} :: SubModuleManagerProperties, {} :: SubModuleManagerImpl))

--[=[
    @type ModuleScriptCollection { ModuleScript }
    @within SubModuleManager
    Simply an array of [ModuleScript] objects.
]=]
export type ModuleScriptCollection = { ModuleScript }

--[=[
    @type SubModuleCollection { PluginSubModule }
    @within SubModuleManager
    Simply an array of [PluginSubModule]s.
]=]
export type SubModuleCollection = { PluginSubModule.PluginSubModule }

export type LoadResultBase = {
	ModuleScript: ModuleScript,
}

--[=[
    @interface LoadSuccess
    @within SubModuleManager
    .Ok true -- Whether the load was successful.
    .ModuleScript ModuleScript -- The module instance that was loaded.
    .Module PluginSubModule -- The returned module after a successful load.

    An object representing a successful module load.
]=]
export type LoadSuccess = LoadResultBase & {
	Ok: true,
	Module: PluginSubModule.PluginSubModule,
}

--[=[
    @interface LoadFailure
    @within SubModuleManager
    .Ok false -- Whether the load was successful.
    .ModuleScript ModuleScript -- The module instance that was loaded.
    .FailureReason string -- A description of why the load failed.

    An object representing an unsuccessful module load.
]=]
export type LoadFailure = LoadResultBase & {
	Ok: false,
	FailureReason: string,
}

--[=[
    @type LoadResult LoadSuccess | LoadFailure
    @within SubModuleManager
    Indicating a generic load result - could be a success or a failure.
]=]
export type LoadResult = LoadSuccess | LoadFailure

--[=[
    @interface ManagedModule
    @within SubModuleManager
    
    .Module PluginSubModule -- The submodule that is being managed.
    .ShouldLoad boolean -- A flag indicating whether the module should and has actually been loaded.
    .NotLoadingReason string? -- A written explanation that is outputted whenever the submodule is invoked, but it is not loaded.
    .ToolbarButton PluginToolbarButton -- The button associated with this submodule. 

    This is an common interfacing data structure that holds all relevant management and loading data about a given submodule.
    It is very useful to pass around the various management methods since each of its data are needed in their own contexts.
]=]
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

--[=[
    @tag constructor
    @since 0.1.0 
    Constructs a new [SubModuleManager].
]=]
function SubModuleManager.new(facade: PluginFacade.PluginFacade): SubModuleManager
	local self = setmetatable({
		_janitor = Janitor.new(),
		ManagedModules = {},
		ManagingModules = false,
		PluginFacade = facade,
	}, SubModuleManager)

	return self
end

--[=[
    @tag utility
    @since 0.1.0
    Validates whether an instance is likely a valid [PluginSubModule].
    Does not `require` it if it is one though.
]=]
function SubModuleManager.ValidPluginSubModule(instance: Instance): boolean
	return instance:IsA("ModuleScript") and instance.Name:split(SUFFIX_SEPARATOR)[2] == SUB_MODULE_SUFFIX
end

--[=[
    @tag methods
    @since 0.1.0
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
    @tag methods
    @since 0.1.0
    Loads all the module scripts inside the collection, validating them.
    Uses [Promises](https://eryn.io/roblox-lua-promise/) internally.
    
    @return Promise<{LoadResult}> -- A promise resolving with an array of module invocation results.
]=]
function SubModuleManager:LoadModules(moduleCollection: ModuleScriptCollection): any
	local loadPromises = {}

	local currentModuleScript: ModuleScript

	local function wrapInSuccess(subModule: PluginSubModule.PluginSubModule): LoadSuccess
		return {
			Ok = true :: true, -- this type casting is fucking wild (removing this will make luau-analyze complain, or at least luau-lsp will)
			ModuleScript = currentModuleScript,
			Module = subModule,
		}
	end

	local function wrapInFailure(reason: string): LoadFailure
		return {
			Ok = false :: false, -- crazy...
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
    @tag methods
    @since 0.1.0
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
	local toolbar = self.PluginFacade:CreateToolbar(toolbarName)

	-- pre-loading and setting up modules
	for _, module in pluginSubModules do
		-- development modules should be skipped in non-development contexts.
		if module.DevelopmentModule and self.PluginFacade.DevelopmentMode then
			Logger.Warn(`Loading submodule [{module.DisplayName}] for development.`)
		else
			continue
		end

		local shouldLoad, reason = module._executors.PreLoad()

		-- creating a button for it
		local moduleId = tostring(module.UID)
		local submoduleButton =
			self.PluginFacade:CreateButton(toolbar, moduleId, module.Tooltip, module.ButtonIcon, module.DisplayName)

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

		-- turning modules on by default if they should be
		if module.ActiveByDefault then
			self:ToggleModuleActivation(self.ManagedModules[moduleId], true)
		end
	end
end

--[=[
    @tag methods
    @since 0.1.0
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
    @tag methods
    @since 0.1.0
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
    @tag methods
    @since 0.1.0
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

	if module.OneClickExecution and module.Active then
		-- deactivate immediately after activating
		self:ToggleModuleActivation(managedModule, false)
	end
end

return SubModuleManager
