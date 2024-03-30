--[=[
    @class DummyPluginModule
    
    Test module for testing PluginSubModule implementation.
]=]

local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)

local newSubModule = PluginSubModule.new({
	ActiveByDefault = false,
	DisplayName = "Dummy Number Generator",
	Tooltip = "Dummy tool for printing random numbers",
	OneClickExecution = true,
})

newSubModule:OnPreLoad(function()
	return true
end)

newSubModule:OnActivate(function()
	print("I'm a plugin that logs a random number to console! >", math.random(1, 10))
end)

return newSubModule
