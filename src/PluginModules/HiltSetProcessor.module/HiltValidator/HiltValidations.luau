--[=[
	@class HiltValidations
	
	Declares a tree of validation rules for all lightsaber hilts, to be used by [HiltValidator].
]=]
local Configurations = require(script.Parent.Parent.ConfigureHilt.Configurations)
local ImportHilt = require(script.Parent.Parent.ImportHilt)

--[=[
	@interface ValidationRule
	@within HiltValidations
	.name string -- the name of the rule
	.validatorFn (hilt: Model) -> (boolean, string?) -- a function that validates if a given hilt follows the rule, returning a flag and an error message if it isn't valid
	.suggestionTip string -- a generic suggestion message that could direct someone in the right direction if the validation isn't met
	.subRules ((hilt: Model) -> ValidationRules)? -- on successful validation, this function can return a list of new rules to validate - rules that DEPEND on this one succeeding
]=]
export type ValidationRule = {
	name: string,
	validatorFn: (hilt: Model) -> (boolean, string?),
	suggestionTip: string,
	subRules: ((hilt: Model) -> ValidationRules)?,
}
--[=[
	@type ValidationRules { ValidationRule }
	@within HiltValidations
	A list of validation rules.
]=]
export type ValidationRules = { ValidationRule }

local HiltValidations = {}

local ExistingAndUniqueConfigurations = {
	name = "AllDescendantsAreUniequelyConfigured",
	validatorFn = function(hilt: Model): boolean
		for _, descendant in hilt:GetDescendants() do
			if descendant:IsA("BasePart") then
				local configuredPrimary = Configurations.IsPrimaryHiltPart(descendant)
				local configuredFixed = Configurations.IsFixedHiltPart(descendant)
				local configuredCrystal = Configurations.IsCrystalHiltPart(descendant)

				local _doNothing = 1
				if configuredPrimary and configuredFixed and configuredCrystal then
					return false,
						`[{descendant:GetFullName()}] can have only one configuration can be applied, not all 3.`
				elseif configuredPrimary and configuredFixed then
					return false, `[{descendant:GetFullName()}] can not be configured as both primary and fixed.`
				elseif configuredPrimary and configuredCrystal then
					return false, `[{descendant:GetFullName()}] can not be configured as both primary and crystal.`
				elseif configuredPrimary then
					_doNothing = 2
				elseif configuredFixed and configuredCrystal then
					return false, `[{descendant:GetFullName()}] can not be configured as both fixed and crystal.`
				elseif configuredFixed then
					_doNothing = 3
				elseif configuredCrystal then
					_doNothing = 4
				else
					return false,
						`[{descendant:GetFullName()}] needs to be configured with one of the 3 part configurations.`
				end
			end
		end
		return true
	end,
	suggestionTip = "Ensure that only ONE of the configurations is applied to each BasePart.",
}

local SingleRules: ValidationRules = {
	ExistingAndUniqueConfigurations,
}
local DoubleRules: ValidationRules = {
	ExistingAndUniqueConfigurations,
}
local StaffRules: ValidationRules = {
	ExistingAndUniqueConfigurations,
}

local UniversalAndCorrectStructure = {
	name = "HasCorrectStructure",
	validatorFn = function(hilt: Model): boolean
		return ImportHilt.IsImportedLightsaberModel(hilt)
	end,
	suggestionTip = "Ensure all 4 sections have a model, and that each section has at least a root.",
	subRules = function(hilt: Model): ValidationRules
		if ImportHilt.IsSingleImportedHilt(hilt) then
			return SingleRules
		elseif ImportHilt.IsDoubleImportedHiltSection(hilt) then
			return DoubleRules
		else
			return StaffRules
		end
	end,
}

local ValidationRules: ValidationRules = {
	UniversalAndCorrectStructure,
}

--[=[
	@prop ValidationRules ValidationRules
	@within HiltValidations
	@since v0.3.0 
	The top-level validation rules that all validations start from.
	Sub-rules are contained in each rule.
]=]
HiltValidations.ValidationRules = ValidationRules

return HiltValidations
