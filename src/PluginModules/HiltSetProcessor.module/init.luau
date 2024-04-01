--!strict
local HiltSetProcessorApp = require(script.HiltSetProcessorApp)
local Permissions = require(script.Parent.Parent.Modules.Permissions)
local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)
local PluginFacade = require(script.Parent.Parent.PluginFacade)
local _ImportHilt = require(script.ImportHilt)
local Config = require(script.Parent.Parent.Config)
local SubModuleManager = require(script.Parent.Parent.Modules.SubModuleManager)
local images = require(script.Parent.Parent.Parent.Assets.images)
local ReactRoblox = require(script.Parent.Parent.Parent.Libraries.ReactRoblox)

local displayName = "Hilt Set Processor"

local HiltSetProcessor = PluginSubModule.new({
	ButtonIcon = images.hilt_collector_3,
	DisplayName = displayName,
	Tooltip = "Handles importing, configuring and validating lightsaber hilt sets",
	ActiveByDefault = Config.DevelopmentMode,
	OneClickExecution = false,
	DevelopmentModule = false,
})

HiltSetProcessor:OnPreLoad(function(): (boolean, string?)
	if Permissions.CanUseHiltProcessor() then
		return true
	else
		return false, "Only SienarTech Architects+ and TKG Developer+ can use the hilt processor."
	end
end)

local pluginWidgetGui: DockWidgetPluginGui
local pluginReactTree

HiltSetProcessor:OnPostLoad(
	function(pluginFacade: PluginFacade.PluginFacade, manager: SubModuleManager.SubModuleManager): boolean?
		local widgetGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 400, 600, 300, 400)
		pluginWidgetGui = pluginFacade:CreateDockWidgetPluginGui("HiltSetProcessorGui", widgetGuiInfo) -- name should not be changed
		pluginWidgetGui.Title = displayName

		pluginWidgetGui:BindToClose(function()
			manager:ToggleModuleActivationFromPlugin(HiltSetProcessor, false)
		end)

		pluginReactTree = ReactRoblox.createRoot(pluginWidgetGui)
		pluginReactTree:render(HiltSetProcessorApp)

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
	pluginReactTree:unmount()
	return true
end)

return HiltSetProcessor
