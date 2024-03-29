local ServerStorage = game:GetService("ServerStorage")

local PluginFacade = require(ServerStorage.TKGSuite.Plugin.PluginFacade)
local Config = require(script.Parent.Config)
local Logger = require(script.Parent.Modules.Logger)
local Permissions = require(script.Parent.Modules.Permissions)

local _TKGSuite = script:FindFirstAncestor(Config.Name.PluginRoot)

local function getToolbarNameSuffixes(pluginFacade: PluginFacade.PluginFacade): (string, string)
	local EMPTY_STRING = ""
	if pluginFacade.DevelopmentMode then
		return ` [DEV-{Config.Version}]`, ` Dev-{Config.Version}`
	else
		return EMPTY_STRING, EMPTY_STRING
	end
end

local function MainPluginExecutor(facade: PluginFacade.PluginFacade, _savedState)
	if not Permissions.CanUsePlugin() then
		Logger.Warn(
			"You cannot use the TKG Plugin Suite. You must be a contributor to the Known Galaxy's development, and ranked as such in SienarTech Systems Development. Contact the current Chief Development Officer for assistance if you need access, but don't have it."
		)
		return
	end

	local displaySuffix, _nameSuffix = getToolbarNameSuffixes(facade)
	local mainPluginToolbar = facade:CreateToolbar(`{Config.Name.Long}{displaySuffix}`)

	-- local app = Roact.createElement(RoactRodux.StoreProvider, {
	-- 	store = store,
	-- }, {
	-- 	App = Roact.createElement(App, {
	-- 		Mouse = plugin:getMouse(),
	-- 	}),
	-- })

	-- local instance = Roact.mount(app, gui, "TKGSuite")

	facade:RegisterPreUnloadHook(function()
		-- Roact.unmount(instance)
		mainPluginToolbar:Destroy()
		-- return store:getState()
	end)
end

return MainPluginExecutor
