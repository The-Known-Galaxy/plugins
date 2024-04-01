--!strict
--[=[
	@class DummyPluginModule
	@private

	Test module for testing PluginSubModule implementation.
]=]

local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)
local PluginFacade = require(script.Parent.Parent.PluginFacade)

local newSubModule = PluginSubModule.new({
	ActiveByDefault = false,
	DisplayName = "Dummy Number Generator",
	Tooltip = "Dummy tool for printing random numbers",
	OneClickExecution = true,
	DevelopmentModule = true,
})

newSubModule:OnPreLoad(function(_pluginFacade: PluginFacade.PluginFacade)
	return true
end)

newSubModule:OnActivate(function(pluginFacade: PluginFacade.PluginFacade)
	print(
		`I'm a plugin that logs a random number to console! {math.random(1, 10)} {if pluginFacade.DevelopmentMode
			then "Oh and I'm in development mode!"
			else "This shouldn't be happening..."}`
	)
	return nil
end)

return newSubModule
