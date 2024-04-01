--!strict
local Permissions = require(script.Parent.Parent.Modules.Permissions)
local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)
local PluginFacade = require(script.Parent.Parent.PluginFacade)
local _ImportHilt = require(script.ImportHilt)
local SubModuleManager = require(script.Parent.Parent.Modules.SubModuleManager)
local images = require(script.Parent.Parent.Parent.Assets.images)

local displayName = "Hilt Set Processor"

local HiltSetProcessor = PluginSubModule.new({
	ButtonIcon = images.hilt_collector_3,
	DisplayName = displayName,
	Tooltip = "Handles importing, configuring and validating lightsaber hilt sets",
	ActiveByDefault = true,
	OneClickExecution = false,
	DevelopmentModule = false,
})

HiltSetProcessor:OnPreLoad(
	function(_pluginFacade: PluginFacade.PluginFacade, _manager: SubModuleManager.SubModuleManager): (boolean, string?)
		if Permissions.CanUseHiltProcessor() then
			return true
		else
			return false, "Only SienarTech Architects+ and TKG Developer+ can use the hilt processor."
		end
	end
)

local pluginGui: DockWidgetPluginGui

HiltSetProcessor:OnPostLoad(
	function(pluginFacade: PluginFacade.PluginFacade, manager: SubModuleManager.SubModuleManager): boolean?
		local widgetGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 400, 600, 300, 400)
		pluginGui = pluginFacade:CreateDockWidgetPluginGui("HiltSetProcessorGui", widgetGuiInfo) -- name should not be changed
		pluginGui.Title = displayName

		pluginGui:BindToClose(function()
			manager:ToggleModuleActivationFromPlugin(HiltSetProcessor, false)
		end)

		return true
	end
)

HiltSetProcessor:OnActivate(
	function(_pluginFacade: PluginFacade.PluginFacade, _manager: SubModuleManager.SubModuleManager): boolean?
		pluginGui.Enabled = true
		return true
	end
)

HiltSetProcessor:OnDeactivate(
	function(_pluginFacade: PluginFacade.PluginFacade, _manager: SubModuleManager.SubModuleManager): boolean?
		pluginGui.Enabled = false
		return true
	end
)

return HiltSetProcessor
