--!strict
--[=[
	@class HiltSetProcessor
	
	Provides functionality to import new lightsaber hilts into the game, as well as other utility functions.
	Heavy lifting done by [ImportHilt].
]=]
local Selection = game:GetService("Selection")

local HiltSetProcessorApp = require(script.HiltSetProcessorApp)
local ImportHilt = require(script.ImportHilt)
local Permissions = require(script.Parent.Parent.Modules.Permissions)
local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)
local PluginFacade = require(script.Parent.Parent.PluginFacade)
local _ImportHilt = require(script.ImportHilt)
local Config = require(script.Parent.Parent.Config)
local SubModuleManager = require(script.Parent.Parent.Modules.SubModuleManager)
local images = require(script.Parent.Parent.Parent.Assets.images)
local Janitor = require(script.Parent.Parent.Parent.Libraries.Janitor)
local React = require(script.Parent.Parent.Parent.Libraries.React)
local ReactRoblox = require(script.Parent.Parent.Parent.Libraries.ReactRoblox)

local ID = {
	ACTION_IMPORT_HILTS_IN_SELECTION = "ImportHiltsFromSelection",
}

local displayName = "Hilt Set Processor"
local pluginIcon = images.hilt_collector_3

local HiltSetProcessor = PluginSubModule.new({
	ButtonIcon = pluginIcon,
	DisplayName = displayName,
	Tooltip = "Handles importing, configuring and validating lightsaber hilt sets",
	ActiveByDefault = Config.DevelopmentMode,
	OneClickExecution = false,
	DevelopmentModule = false,
})

local janitor

HiltSetProcessor:OnPreLoad(function(): (boolean, string?)
	if Permissions.CanUseHiltProcessor() then
		return true
	else
		return false, "Only SienarTech Architects+ and TKG Developer+ can use the hilt processor."
	end
end)
local pluginWidgetGui: DockWidgetPluginGui

HiltSetProcessor:OnPostLoad(
	function(pluginFacade: PluginFacade.PluginFacade, manager: SubModuleManager.SubModuleManager): boolean?
		-- janitor for easy object cleanup
		janitor = Janitor.new()

		-- creating widget gui
		local widgetGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 400, 600, 300, 400)
		pluginWidgetGui = pluginFacade:CreateDockWidgetPluginGui("HiltSetProcessorGui", widgetGuiInfo) -- name should not be changed
		pluginWidgetGui.Title = displayName

		pluginWidgetGui:BindToClose(function()
			manager:ToggleModuleActivationFromPlugin(HiltSetProcessor, false)
		end)

		local pluginReactTree = ReactRoblox.createRoot(pluginWidgetGui)
		pluginReactTree:render(React.createElement(HiltSetProcessorApp))
		janitor:Add(pluginReactTree, "unmount", "RoactTree")

		-- creating actions
		local importAction = pluginFacade:CreatePluginAction(
			ID.ACTION_IMPORT_HILTS_IN_SELECTION,
			"Import hilts from selection",
			"Iterates through all selected Models and imports them into lightsaber hilt models.",
			pluginIcon,
			true
		)

		janitor:Add(
			importAction.Triggered:Connect(function()
				ImportHilt.FilterSelectionAndImport(Selection:Get())
			end),
			nil,
			"ImportActionTriggered"
		)

		return true
	end
)

HiltSetProcessor:OnActivate(function(): boolean?
	pluginWidgetGui.Enabled = true
	return true
end)

HiltSetProcessor:OnDeactivate(function(): boolean?
	pluginWidgetGui.Enabled = false
	return true
end)

HiltSetProcessor:OnPreUnload(function(): boolean?
	janitor:Destroy()
	return true
end)

return HiltSetProcessor
