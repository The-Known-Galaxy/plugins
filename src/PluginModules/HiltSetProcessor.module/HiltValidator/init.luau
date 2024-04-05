--[=[
	@class HiltValidator
	
	Provides functions for validating instances (with [HiltValidations]) as well-formed lightsaber hilts, and for outputting the results.
]=]
local HiltValidations = require(script.HiltValidations)
local Logger = require(script.Parent.Parent.Parent.Modules.Logger)

--[=[
	@interface SelectionValidation
	@within HiltValidator
	.allSuccessful boolean -- whether all the hilts are valid
	.validHilts number -- the number of valid hilts
	.invalidHilts number -- the number of invalid hilts
	.resultsPerInstance SelectionValidationResults -- a list of validation results per hilt that has been validated

	Top-level instance, describing a validation run against a whole selection of models.
]=]
export type SelectionValidation = {
	allSuccessful: boolean,
	validHilts: number,
	invalidHilts: number,
	resultsPerInstance: SelectionValidationResults,
}

--[=[
	@type SelectionValidationResults { ValidationResultForInstance }
	@within HiltValidator

	A list of validation results for each instance in a selection.
]=]
export type SelectionValidationResults = { ValidationResultForInstance }

--[=[
	@interface ValidationResultForInstance
	@within HiltValidator
	.model Model -- the specific hilt model that has been validated
	.evaluation HiltValidation -- the list of results for all the validations ran against this instance

	A set of validaation results, tied to a specific instance that the validations were run on.
]=]
export type ValidationResultForInstance = {
	model: Model,
	evaluation: HiltValidation,
}

--[=[
	@interface HiltValidation
	@within HiltValidator
	.isValidHilt boolean -- whether the hilt is valid
	.validationsSuccessful number -- the number of successful validations
	.validationsUnsuccessful number -- the number of unsuccessful validations
	.results ValidationResults -- the list of validations ran and their results

	Validation results for a specific model, describing all the validations ran and whether the model is a valid hilt.
]=]

export type HiltValidation = {
	isValidHilt: boolean,
	validationsSuccessful: number,
	validationsUnsuccessful: number,
	results: ValidationResults,
}

--[=[
	@type ValidationResults { ValidationResult }
	@within HiltValidator

	A list of validation results.
]=]
export type ValidationResults = { ValidationResult }

--[=[
	@interface ValidationResult
	@within HiltValidator
	.validationName string -- the name of the validation
	.success boolean -- whether it was successful, and the validation passed
	.message string -- a message, either describing the problem that occurred from the validation failing, or saying it passed
	
	A description of a singular validation run, and its outcome.
]=]
export type ValidationResult = {
	validationName: string,
	success: boolean,
	message: string,
}

local HiltValidator = {}

--[=[
	@since v0.3.0
	Runs a validations on a selection of potential hilt [Model]s.
	Assumes every instance in the selection is a model.
	Returns an object that describes the results of running all validations against all models in the selection.
]=]
function HiltValidator.RunValidationsOnSelection(selection: { Model }): SelectionValidation
	local validHilts = 0
	local failedHilts = 0
	local validationsPerInstance: SelectionValidationResults = {}

	for _, instance in selection do
		local results = HiltValidator.RunValidations(instance)
		local hiltValidation = HiltValidator.EvaluateValidationResults(results)

		if hiltValidation.isValidHilt then
			validHilts += 1
		end

		table.insert(validationsPerInstance, {
			model = instance,
			evaluation = hiltValidation,
		})
	end

	failedHilts = #selection - validHilts

	return {
		allSuccessful = failedHilts == 0,
		validHilts = validHilts,
		invalidHilts = failedHilts,
		resultsPerInstance = validationsPerInstance,
	}
end

--[=[
	@since v0.3.0
	Runs all the existing validations against a potential hilt, which is a [Model] instance.
	Returns an array of validation results - each object describing the outcome of the validation against that model.
	Since some validations depend on the success of others, it recursively parses the validation tree until there are no more validations to run.
]=]
function HiltValidator.RunValidations(potentialHilt: Model): ValidationResults
	local results = {}

	local function validate(validations: HiltValidations.ValidationRules): ()
		for _, rule in validations do
			local passesValidation, failureMessage = rule.validatorFn(potentialHilt)

			local newResultObject: ValidationResult = {
				validationName = rule.name,
				success = passesValidation,
				message = if passesValidation then "Pass." else `{failureMessage} {rule.suggestionTip}`,
			}
			table.insert(results, newResultObject)

			-- recursively parsing new rules if the above ones are valid
			if passesValidation and rule.subRules ~= nil then
				local newRules = rule.subRules(potentialHilt)
				if #newRules > 0 then
					validate(newRules)
				end
			end
		end
	end

	validate(HiltValidations.ValidationRules)

	return results
end

--[=[
	@since v0.3.0
	Evaluates all the validation results for one specific model, deciding whether the model is a valid hilt, and returning the number of successful and unsuccessful validations.
]=]
function HiltValidator.EvaluateValidationResults(results: ValidationResults): HiltValidation
	local successCount = 0
	local failureCount = 0

	for _, result in results do
		if result.success then
			successCount += 1
		end
	end

	failureCount = #results - successCount

	return {
		isValidHilt = failureCount == 0,
		validationsSuccessful = successCount,
		validationsUnsuccessful = failureCount,
		results = results,
	}
end

--[=[
	@tag utility
	@since v0.3.0
	Outputs all an entire selection validation result to the output in a nice format.
]=]
function HiltValidator.OutputSelectionValidation(selectionValidation: SelectionValidation)
	print("\n\n\n")
	Logger.Print(`Validation at {DateTime.now():FormatLocalTime("LTS", "en-gb")}...`)

	local evaluatedHilts: { Model } = {}
	for _, instancedResult in selectionValidation.resultsPerInstance do
		table.insert(evaluatedHilts, instancedResult.model)
		local modelSuccess = instancedResult.evaluation.validationsSuccessful
		local modelFail = instancedResult.evaluation.validationsUnsuccessful
		local modelTotal = modelSuccess + modelFail
		local modelMessage =
			`[{instancedResult.model}]: {modelTotal} total, {modelSuccess} successful, {modelFail} unsuccessful`
		if instancedResult.evaluation.isValidHilt then
			Logger.Print(modelMessage)
		else
			Logger.Warn(modelMessage)
		end

		for _, validation in instancedResult.evaluation.results do
			local message = `    [{instancedResult.model} / {validation.validationName}]: {validation.message}`
			if validation.success then
				Logger.Print(message)
			else
				Logger.Warn(message)
			end
		end
	end

	Logger.Print("Instances validated:")
	for _, model in evaluatedHilts do
		Logger.Print(`instance: <{model.Name}> from [{model:GetFullName()}]`)
	end

	local finalMessage =
		`{selectionValidation.validHilts + selectionValidation.invalidHilts} total, {selectionValidation.validHilts} valid, {selectionValidation.invalidHilts} invalid`

	if selectionValidation.allSuccessful then
		Logger.Print(`SUCCESS: {finalMessage}`)
		Logger.Print("All hilts are valid!")
	else
		Logger.Warn(`FAIL: {finalMessage}`)
		Logger.Warn("Some hilts need work...")
	end
end

return HiltValidator
