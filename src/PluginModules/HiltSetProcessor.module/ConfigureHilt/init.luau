--[=[
	@class ConfigureHilt
	
	A module for handling all the logic to do with configuring an already imported hilt.
	Have a look at [ImportHilt] for the previous logic.
]=]
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Configurations = require(script.Configurations)
local ImportHilt = require(script.Parent.ImportHilt)
local Config = require(script.Parent.Parent.Parent.Config)
local Logger = require(script.Parent.Parent.Parent.Modules.Logger)
local Llama = require(script.Parent.Parent.Parent.Parent.Libraries.Llama)

local ConfigureHilt = {}

--[=[
	@since v0.3.0
	Takes in a specific action ID, and compares them against known IDs from [Config.ActionAndMenuId].
	If a valid configuration function is found, performs that function on the entire set of selected objects. 
]=]
function ConfigureHilt.ConfigureSelectionByActionId(selection: { Instance }, pluginActionId: string)
	local filteredSelection = ConfigureHilt.FilterSelectionForConfigurableHiltParts(selection)

	if #filteredSelection == 0 then
		return
	end

	local actionFunction
	local completionMessage
	if pluginActionId:find(Config.ActionAndMenuId.ACTION_SET_AS_PRIMARY_PART) then
		actionFunction = Configurations.MakePrimaryHiltPart
		completionMessage = "Made [%s] into a primary hilt part."
	elseif pluginActionId:find(Config.ActionAndMenuId.ACTION_SET_AS_FIXED_PART) then
		actionFunction = Configurations.MakeFixedHiltPart
		completionMessage = "Made [%s] into a fixed hilt part."
	elseif pluginActionId:find(Config.ActionAndMenuId.ACTION_SET_AS_CRYSTAL_PART) then
		actionFunction = Configurations.MakeCrystalPart
		completionMessage = "Made [%s] into a crystal hilt part."
	end

	if actionFunction then
		ChangeHistoryService:SetWaypoint("ConfigureSelectionParts")
		for _, part in filteredSelection do
			actionFunction(part)
			Logger.Print(completionMessage:format(part:GetFullName()))
		end
	end
	return
end

--[=[
	@tag utility
	@since v0.3.0  
	Filters a given selection for only the parts that can be configured (their attributes changed).
]=]
function ConfigureHilt.FilterSelectionForConfigurableHiltParts(selection: { Instance }): { BasePart }
	return Llama.List.filter(selection, ConfigureHilt.IsConfigurableHiltPart)
end

--[=[
	@tag utility
	@since v0.3.0
	Checks whether a given instance is a [BasePart] and if it's inside an already imported lightsaber hilt model.
	This is a pre-requisite for doing any part-level hilt configuration.  
]=]
function ConfigureHilt.IsConfigurableHiltPart(part: Instance): boolean
	return part:IsA("BasePart") and ImportHilt.IsInsideImportedModel(part)
end

return ConfigureHilt
