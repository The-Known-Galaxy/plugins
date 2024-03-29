local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ServerStorage.TKGSuite.Plugin.Config)
local PluginFacade = require(ServerStorage.TKGSuite.Plugin.PluginFacade)

local _TKGSuite = script:FindFirstAncestor(Config.Name.PluginRoot)

local function getSuffix(facade: PluginFacade.PluginFacade): (string, string)
	if facade.DevelopmentMode then
		return ` [DEV-{Config.Version}]`, `Dev-{Config.Version}`
	else
		return "", ""
	end
end

local function MainPluginExecutor(facade: PluginFacade.PluginFacade, _savedState)
	local displaySuffix, nameSuffix = getSuffix(facade)
	local toolbar = facade:CreateToolbar(`{Config.Name.Long}{displaySuffix}`)
	local toggleButton =
		facade:CreateButton(toolbar, `{Config.Name.Short}`, `Open the {Config.Name.Long} window`, Config.MainIcon)

	-- local store = Rodux.Store.new(Reducer, savedState)

	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 0, 0)
	local gui = facade:CreateDockWidgetPluginGui(`{Config.Name.Long}{nameSuffix}`, info)
	gui.Name = `{Config.Name.Long}{nameSuffix}`
	gui.Title = `{Config.Name.Long}{displaySuffix}`
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	toggleButton:SetActive(gui.Enabled)

	local connection = toggleButton.Click:Connect(function()
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
