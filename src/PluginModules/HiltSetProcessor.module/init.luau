--!strict
--[=[
	@class HiltSetProcessor
	
	Provides functionality to import new lightsaber hilts into the game, as well as other utility functions.
	Heavy lifting done by [ImportHilt].
]=]
local Selection = game:GetService("Selection")

local HiltSetProcessorApp = require(script.Interface.HiltSetProcessorApp)
local ImportHilt = require(script.ImportHilt)
local Permissions = require(script.Parent.Parent.Modules.Permissions)
local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)
local PluginFacade = require(script.Parent.Parent.PluginFacade)
local _ImportHilt = require(script.ImportHilt)
local Config = require(script.Parent.Parent.Config)
local PluginWidgetFrame = require(script.Parent.Parent.Modules.Interface.PluginWidgetFrame)
local SubModuleManager = require(script.Parent.Parent.Modules.SubModuleManager)
local images = require(script.Parent.Parent.Parent.Assets.images)
local Janitor = require(script.Parent.Parent.Parent.Libraries.Janitor)
local React = require(script.Parent.Parent.Parent.Libraries.React)
local ReactRoblox = require(script.Parent.Parent.Parent.Libraries.ReactRoblox)

local displayName = "Hilt Set Processor"
local pluginIcon = images.hilt_collector_3

local HiltSetProcessor = PluginSubModule.new({
	ButtonIcon = pluginIcon,
	DisplayName = displayName,
	Tooltip = "Handles importing, configuring and validating lightsaber hilt sets",
	ActiveByDefault = false,
	OneClickExecution = false,
	DevelopmentModule = false,
})

local janitor
local configurationActionMenu: PluginMenu

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

		-- creating actions
		local importAction = pluginFacade:CreatePluginAction(
			Config.ActionAndMenuId.ACTION_IMPORT_HILTS_IN_SELECTION,
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

		local setAsPrimaryPartAction = pluginFacade:CreatePluginAction(
			Config.ActionAndMenuId.ACTION_SET_AS_PRIMARY_PART,
			"Set as Material-influenced Primary Hilt Part",
			"Sets a given BasePart inside an imported hilt as the primary part. These don't have materials",
			"",
			false
		)
		local setAsFixedPartAction = pluginFacade:CreatePluginAction(
			Config.ActionAndMenuId.ACTION_SET_AS_FIXED_PART,
			"Set as Static Fixed Part",
			"Sets a given BasePart inside an imported hilt as a fixed part. These are influenced by materials.",
			"",
			false
		)
		local setAsCrystalPartAction = pluginFacade:CreatePluginAction(
			Config.ActionAndMenuId.ACTION_SET_AS_CRYSTAL_PART,
			"Set as Crystal Part",
			"Sets a given BasePart inside an imported hilt as a crystal part. These change depending on crystal.",
			"",
			false
		)

		-- creating plugin menus
		-- creating context menu for managing parts post-import
		configurationActionMenu =
			pluginFacade:CreatePluginMenu(Config.ActionAndMenuId.MENU_CONFIGURE_HILT_PART, "Configure Hilt Part", "")

		configurationActionMenu:AddAction(setAsPrimaryPartAction)
		configurationActionMenu:AddAction(setAsFixedPartAction)
		configurationActionMenu:AddAction(setAsCrystalPartAction)

		-- creating widget gui
		local widgetGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 400, 600, 300, 400)
		pluginWidgetGui = pluginFacade:CreateDockWidgetPluginGui("HiltSetProcessorGui", widgetGuiInfo) -- name should not be changed
		pluginWidgetGui.Title = displayName

		pluginWidgetGui:BindToClose(function()
			manager:ToggleModuleActivationFromPlugin(HiltSetProcessor, false)
		end)

		local pluginReactTree = ReactRoblox.createRoot(pluginWidgetGui)
		pluginReactTree:render(React.createElement(PluginWidgetFrame, {}, {
			HiltSetProcessorApp = React.createElement(HiltSetProcessorApp, {
				configurationMenu = configurationActionMenu,
			}),
		}))
		janitor:Add(pluginReactTree, "unmount", "RoactTree")

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
	configurationActionMenu:Clear()
	janitor:Destroy()
	return true
end)

return HiltSetProcessor
