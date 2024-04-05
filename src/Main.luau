local PluginFacade = require(script.Parent.PluginFacade)
local Config = require(script.Parent.Config)
local InterfaceConfig = require(script.Parent.Modules.Interface.InterfaceConfig)
local Logger = require(script.Parent.Modules.Logger)
local Permissions = require(script.Parent.Modules.Permissions)
local SubModuleManager = require(script.Parent.Modules.SubModuleManager)

local _TKGSuite = script:FindFirstAncestor(Config.Name.PluginRoot)

local function getToolbarNameSuffixes(pluginFacade: PluginFacade.PluginFacade): (string, string)
	local EMPTY_STRING = ""
	if pluginFacade.DevelopmentMode then
		return ` [DEV-{Config.Version}]`, ` Dev-{Config.Version}`
	else
		return ` {Config.Version}`, EMPTY_STRING
	end
end

local function MainPluginExecutor(facade: PluginFacade.PluginFacade, _savedState)
	if not Permissions.CanUsePlugin() then
		Logger.Warn(
			"You cannot use the TKG Plugin Suite. You must be a contributor to the Known Galaxy's development, and ranked as such in SienarTech Systems Development. Contact the current Chief Development Officer for assistance if you need access, but don't have it."
		)
		return
	end

	-- deciding theme from access level
	InterfaceConfig.Theme.Colours = Permissions.GetAccessLevel().Theme

	local displaySuffix, _nameSuffix = getToolbarNameSuffixes(facade)
	local toolbarName = `{Config.Name.Long}{displaySuffix}`
	facade:CreateToolbar(toolbarName)

	local manager = SubModuleManager.new(facade)
	local possibleSubModuleInstances = manager:CollectModules(script.Parent.PluginModules)
	manager:LoadModules(possibleSubModuleInstances):andThen(function(results: { SubModuleManager.LoadResult })
		local loadedSubModules: SubModuleManager.SubModuleCollection = {}

		-- processing module loading
		for _, moduleLoad in results do
			if moduleLoad.Ok then
				table.insert(loadedSubModules, moduleLoad.Module)
			else
				Logger.Warn(`{moduleLoad.ModuleScript.Name} failed to load because: {moduleLoad.FailureReason}`)
			end
		end

		-- running life cycles
		manager:RunLifeCycles(loadedSubModules, toolbarName)
	end)

	facade:RegisterPreUnloadHook(function()
		manager:UnloadAllModules()
	end)
end

return MainPluginExecutor
