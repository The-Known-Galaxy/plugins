local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local PluginFacade = require(ServerStorage.TKGSuite.Plugin.PluginFacade)
local Config = require(script.Parent.Config)
local Logger = require(script.Parent.Modules.Logger)
local Permissions = require(script.Parent.Modules.Permissions)

local _TKGSuite = script:FindFirstAncestor(Config.Name.PluginRoot)

local function getToolbarNameSuffixes(pluginFacade: PluginFacade.PluginFacade): (string, string)
	local EMPTY_STRING = ""
	if pluginFacade.DevelopmentMode then
		return ` [DEV-{Config.Version}]`, `Dev-{Config.Version}`
	else
		return EMPTY_STRING, EMPTY_STRING
	end
end

local function MainPluginExecutor(facade: PluginFacade.PluginFacade, _savedState)
	local displaySuffix, nameSuffix = getToolbarNameSuffixes(facade)
	local toolbar = facade:CreateToolbar(`{Config.Name.Long}{displaySuffix}`)
	local toggleButton = facade:CreateButton(toolbar, `{Config.Name.Long}`, `Open {Config.Name.Short}`, Config.MainIcon)
	-- local store = Rodux.Store.new(Reducer, savedState)

	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 0, 0)
	local gui = facade:CreateDockWidgetPluginGui(`{Config.Name.Long}{nameSuffix}`, info)
	gui.Name = `{Config.Name.Long}{nameSuffix}`
	gui.Title = `{Config.Name.Long}{displaySuffix}`
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	toggleButton:SetActive(gui.Enabled)

	local connection = toggleButton.Click:Connect(function()
		if not Permissions.CanUsePlugin() then
			Logger.Warn(
				"You are not allowed to use this plugin! You must be some kind of contributor to the Known Galaxy."
			)
			return
		end
		gui.Enabled = not gui.Enabled
		toggleButton:SetActive(gui.Enabled)
	end)

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
		connection:Disconnect()
		-- return store:getState()
	end)

	if RunService:IsRunning() then
		return
	end

	local unloadConnection
	unloadConnection = gui.AncestryChanged:Connect(function()
		print(`New {Config.Name.Long} version coming online; unloading the old version`)
		unloadConnection:Disconnect()
		facade:UnloadPlugin()
	end)
end

return MainPluginExecutor
