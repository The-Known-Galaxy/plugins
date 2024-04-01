--!strict
local Permissions = require(script.Parent.Parent.Modules.Permissions)
local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)
local PluginFacade = require(script.Parent.Parent.PluginFacade)
local ImportHilt = require(script.ImportHilt)

local HiltSetProcessor = PluginSubModule.new({
	ButtonIcon = nil,
	DisplayName = "Hilt Set Processor",
	Tooltip = "Handles importing, configuring and validating lightsaber hilt sets",
	ActiveByDefault = false,
	OneClickExecution = true,
	DevelopmentModule = false,
})

HiltSetProcessor:OnPreLoad(function(_pluginFacade: PluginFacade.PluginFacade): (boolean, string?)
	if Permissions.CanUseHiltProcessor() then
		return true
	else
		return false, "Only SienarTech Architects+ and TKG Developer+ can use the hilt processor."
	end
end)

HiltSetProcessor:OnActivate(function(_pluginFacade: PluginFacade.PluginFacade): boolean?
	return ImportHilt()
end)

return HiltSetProcessor
