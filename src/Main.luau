local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local images = require(ServerStorage.TKGSuite.Assets.images)
local PluginFacade = require(ServerStorage.TKGSuite.Plugin.PluginFacade)

local _TKGSuite = script:FindFirstAncestor("TKGSuite")

local function getSuffix(facade: PluginFacade.PluginFacade): (string, string)
	if facade.DevelopmentMode then
		return " [DEV]", "Dev"
	else
		return "", ""
	end
end

local function MainPluginExecutor(facade: PluginFacade.PluginFacade, _savedState)
	local displaySuffix, nameSuffix = getSuffix(facade)
	local toolbar = facade:CreateToolbar("TKGSuite" .. displaySuffix)
	local toggleButton = facade:CreateButton(toolbar, "TKGSuite", "Open the TKGSuite window", images.tkg)

	-- local store = Rodux.Store.new(Reducer, savedState)

	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 0, 0)
	local gui = facade:CreateDockWidgetPluginGui("TKGSuite" .. nameSuffix, info)
	gui.Name = "TKGSuite" .. nameSuffix
	gui.Title = "TKGSuite " .. displaySuffix
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
		print("New TKGSuite version coming online; unloading the old version")
		unloadConnection:Disconnect()
		facade:UnloadPlugin()
	end)
end

return MainPluginExecutor
