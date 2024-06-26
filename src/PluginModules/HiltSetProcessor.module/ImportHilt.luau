--[=[
	@class ImportHilt

	Original code by [Nidoxs](https://github.com/Nidoxs).
	Refactored and improved by [ShadowEngineer](https://github.com/ShadowEngineer).

	Handles all logic related to importing lightsabers.
]=]
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local SelectionService = game:GetService("Selection")

local NO_SELECTION_ERROR = "You need to select something before running the import hilt function!"
local INVALID_SELECTION_ERROR = "Selection at (%s) was not a model. Setup has been skipped for this selection."
local DETAIL_NAME = "%s_%s_detail%s_%d"
local INVALID_CHILDREN_ERROR =
	"Invalid child (%s<%s>) found in (%s). Remove anything that isn't a BasePart of MeshPart and try again. Setup has been skipped for this selection."

-- in global space
local CLONE_OFFSET = Vector3.new(0, 1, 0)

local Configurations = require(script.Parent.ConfigureHilt.Configurations)
local ImportData = require(script.Parent.ImportData)
local Logger = require(script.Parent.Parent.Parent.Modules.Logger)
local Llama = require(script.Parent.Parent.Parent.Parent.Libraries.Llama)
local t = require(script.Parent.Parent.Parent.Parent.Libraries.t)

--[=[
	@within ImportHilt
	@private
	Checks whether a given string contains any of the keywords given.
]=]
local function nameMatchesKeyWords(name: string, keywords: ImportData.KeyWordList): boolean
	name = name:lower()
	for _, keyword in keywords do
		if name:find(keyword:lower()) then
			return true
		end
	end
	return false
end

local ImportHilt = {}

--[=[
	@since v0.1.0 
	Main executor function.
	Also the return-value of this module.

	Processes all objects in the selection, validates them as something you can import, and then turns it into a new model.
	Achieves this by checking each child part in the original mesh selection against a selection of key words that imply what section it belongs to.

	New model form:
	```
	Model: lightsaber_name
		Model: lightsaber_name
			Model: emitter
				Model: details
					{ BasePart }
				BasePart: root
			Model: grip
				Model: details
					{ BasePart }
				BasePart: root
			Model: pommel
				Model: details
					{ BasePart }
				BasePart: root
			Model: switch
				Model: details
					{ BasePart }
				BasePart: root
		Model: lightsaber_name_double_grip
			Model: details
		Model: lightsaber_name_staff
			Model: details
	```

	Expects an Instance of the form:
	```
	Model: Lightsaber Name
		{ BasePart }
	```
]=]
function ImportHilt.Import(selection: { Instance }): ()
	local importedInstances = {}

	ChangeHistoryService:SetWaypoint("Import lightsabers")

	for _, selectedInstance in ipairs(selection) do
		if not selectedInstance:IsA("Model") then
			Logger.Warn(INVALID_SELECTION_ERROR:format(selectedInstance:GetFullName()))
			continue
		end

		local skipThisInstance = false
		for _, childFound in pairs(selectedInstance:GetChildren()) do
			if not childFound:IsA("BasePart") then
				Logger.Warn(
					INVALID_CHILDREN_ERROR:format(childFound.ClassName, childFound.Name, selectedInstance:GetFullName())
				)
				skipThisInstance = true
			end
		end

		if skipThisInstance then
			continue
		end

		-- making a copy in order to not alter the previous mesh if the old one wants to be kept around
		local _orientation, boundingBox = selectedInstance:GetBoundingBox()
		local newInstance = selectedInstance:Clone()
		newInstance.Parent = selectedInstance.Parent
		newInstance:PivotTo(newInstance:GetPivot() + Vector3.new(0, boundingBox.Y, 0) + CLONE_OFFSET)

		-- this might be put in some names, so removing
		local setName = newInstance.Name:lower():gsub("_lightsaber", ""):gsub(" ", "_"):gsub("-", "_")

		local setModel = Instance.new("Model")
		setModel.Name = setName

		-- double hilt models
		local doubleModel = Instance.new("Model")
		doubleModel.Name = `{setName}{ImportData.doubleGripSuffix}`

		local doubleDetailsModel = Instance.new("Model")
		doubleDetailsModel.Name = "details"

		-- staff section models
		local staffModel = Instance.new("Model")
		staffModel.Name = `{setName}{ImportData.staffSuffix}`

		local staffDetailsModel = Instance.new("Model")
		staffDetailsModel.Name = "details"

		local doubleRootPart
		local doubleDetailCount = 0

		local staffRootPart
		local staffDetailCount = 0

		-- finding all the BaseParts that belong to each of the 4 sections, and processing them individually
		for sectionIndex, sectionName: ImportData.SectionName in ImportData.sections do
			local keywordsForSection = ImportData.keywords.sectionKeywords[sectionIndex]
			local hiltParts = newInstance:GetChildren()

			local sectionModel = Instance.new("Model")
			sectionModel.Name = sectionName
			sectionModel.Parent = setModel

			local detailsModel = Instance.new("Model")
			detailsModel.Name = "details"
			detailsModel.Parent = sectionModel

			local rootForSection

			local detailCount = 0

			-- checking each hilt part and finding what it belongs to
			for _, child: BasePart in hiltParts do
				local childName = child.Name
				child.Material = ImportData.basePartMaterial

				local childIsASectionPart = nameMatchesKeyWords(childName, keywordsForSection)
				local childIsADoublePart = nameMatchesKeyWords(childName, ImportData.keywords.doubleGrip)
				local childIsAStaffPart = nameMatchesKeyWords(childName, ImportData.keywords.staffGrip)

				if childIsASectionPart or childIsADoublePart or childIsAStaffPart then
					-- checking for what kind of part it is by searching for keyword matches against the part's name
					local childIsAPrimaryPart = nameMatchesKeyWords(childName, ImportData.keywords.primary)
					local childIsARootPart = nameMatchesKeyWords(childName, ImportData.keywords.root)
					local childIsACrystalPart = nameMatchesKeyWords(childName, ImportData.keywords.crystal)

					-- configuring part
					if childIsAPrimaryPart or childIsARootPart then
						Configurations.MakePrimaryHiltPart(child)
					else
						Configurations.MakeFixedHiltPart(child)
					end
					if childIsACrystalPart then
						Configurations.MakeCrystalPart(child)
					end

					-- these apparently don't matter anymore, but gg
					local isSecondaryPart = nameMatchesKeyWords(childName, ImportData.keywords.secondary)
					local isTertiaryPart = nameMatchesKeyWords(childName, ImportData.keywords.tertiary)
					local isFixedPart = nameMatchesKeyWords(childName, ImportData.keywords.fixed)

					local partCategory = ""

					if isSecondaryPart then
						partCategory = "(secondary_old)"
					elseif isTertiaryPart then
						partCategory = "(tertiary_old)"
					elseif isFixedPart then
						partCategory = "(fixed_old)"
					elseif childIsACrystalPart then
						partCategory = "(crystal)"
					end

					-- if a root part for the given section does not yet exist, then set it up as a root part if it matches root part keywords
					-- everything that isn't a root part is detail
					if childIsADoublePart then
						-- a part for a double hilt
						if not doubleRootPart and childIsARootPart then
							child.Name = ImportData.rootPartName
							child.Parent = doubleModel
							doubleRootPart = child
							doubleModel.PrimaryPart = child
						else
							doubleDetailCount += 1
							child.Name = DETAIL_NAME:format(setName, "double", partCategory, doubleDetailCount)
							child.Parent = doubleDetailsModel
						end
					elseif childIsAStaffPart then
						-- a part for a staff
						if not staffRootPart and childIsARootPart then
							child.Name = ImportData.rootPartName
							child.Parent = staffModel
							staffRootPart = child
							staffModel.PrimaryPart = child
						else
							staffDetailCount += 1
							child.Name = DETAIL_NAME:format(setName, "staff", partCategory, staffDetailCount)
							child.Parent = staffDetailsModel
						end
					else
						-- regular hilt part in a given section
						if not rootForSection and childIsARootPart then
							child.Name = ImportData.rootPartName
							child.Parent = sectionModel
							rootForSection = child
							sectionModel.PrimaryPart = child
						else
							detailCount += 1
							child.Name = DETAIL_NAME:format(setName, sectionName, partCategory, detailCount)
							child.Parent = detailsModel
						end
					end
				end
			end
		end

		setModel.Parent = newInstance
		doubleModel.Parent = newInstance
		doubleDetailsModel.Parent = doubleModel
		staffModel.Parent = newInstance
		staffDetailsModel.Parent = staffModel
		newInstance.Name = setName

		table.insert(importedInstances, newInstance)

		Logger.Print(`Imported hilt [{setName}] from [{selectedInstance:GetFullName()}]`)
	end

	SelectionService:Set(importedInstances)
end

--[=[
	@since v0.3.0
	Filters a selection for importable models, and then imports them.
]=]
function ImportHilt.FilterSelectionAndImport(selection: { Instance }): ()
	selection = ImportHilt.FilterSelectionForImportableModels(selection)
	if not (#selection > 0) then
		Logger.Warn(NO_SELECTION_ERROR)
		return
	end

	ImportHilt.Import(selection)
end

--[=[
	@tag utility
	@since v0.3.0  
	Checks whether a given model is an importable one by checking its contents.
]=]
function ImportHilt.IsImportableModel(instance: Instance): boolean
	local isModel = instance:IsA("Model")
	if not isModel then
		return false
	end

	-- checking all children are base parts, and that it has children
	local children = instance:GetChildren()
	if #children == 0 then
		return false
	end

	for _, child in children do
		if not child:IsA("BasePart") then
			return false
		end
	end

	-- any of its ancestors ARE NOT imported lightsaber models
	-- in other words, this isn't a model inside an already imported model
	return not ImportHilt.IsInsideImportedModel(instance)
end

--[=[
	@tag utility
	@since v0.3.0
	Checks whether a given instance is inside of an already imported hilt model, recursively.  
]=]
function ImportHilt.IsInsideImportedModel(recursiveInstance: Instance): boolean
	if recursiveInstance == workspace then
		return false
	end

	local isImportedModel = ImportHilt.IsImportedLightsaberModel(recursiveInstance)
	if isImportedModel then
		return true
	end

	if recursiveInstance.Parent then
		return ImportHilt.IsInsideImportedModel(recursiveInstance.Parent)
	else
		return false
	end
end

--[=[
	@tag utility
	@since v0.3.0
	Checks whether a given model is a fully imported lightsaber model (or its double-grip variant).
	Returns a message indicating why it isn't, if it isn't.
]=]
function ImportHilt.IsImportedLightsaberModel(instance: Instance): (boolean, string?)
	local singlePass, singleMessage = ImportHilt.IsSingleImportedHilt(instance)
	local doublePass, doubleMessage = ImportHilt.IsDoubleImportedHiltSection(instance)
	local staffPass, staffMessage = ImportHilt.IsStaffImportedHiltSection(instance)
	if singlePass or doublePass or staffPass then
		return true
	else
		-- only putting double message if the hilt is supposed to be a double hilt but doesn't match structure
		local message = nil
		if ImportHilt.HasDoubleName(instance) then
			message = doubleMessage
		elseif ImportHilt.HasStaffName(instance) then
			message = staffMessage
		else
			message = singleMessage
		end

		return false, `Not structured like a single, double or staff hilt. Raw description: {message}.`
	end
end

--[=[
	@tag utility
	@since v0.3.1 
	Checks whether a model is named like a double hilt. 
]=]
function ImportHilt.HasDoubleName(instance: Instance): boolean
	return instance.Name:find(ImportData.doubleGripSuffix) ~= nil
end

--[=[
	@tag utility
	@since v0.3.1 
	Checks whether a model is named like a double hilt. 
]=]
function ImportHilt.HasStaffName(instance: Instance): boolean
	return instance.Name:find(ImportData.staffSuffix) ~= nil
end

--[=[
	@tag utility
	@since v0.3.0 
	Checks whether a given instance is a valid single lightsaber hilt.
	Returns a message indicating why it isn't, if it isn't.
]=]
function ImportHilt.IsSingleImportedHilt(instance: Instance): (boolean, string?)
	local sectionCheck = t.instanceIsA("Model", {
		root = t.instanceIsA("BasePart"),
		details = t.instanceIsA("Model"),
	})

	local importedStructureCheck = t.instanceIsA("Model", {
		[ImportData.sections[1]] = sectionCheck,
		[ImportData.sections[2]] = sectionCheck,
		[ImportData.sections[3]] = sectionCheck,
		[ImportData.sections[4]] = sectionCheck,
	})

	return importedStructureCheck(instance)
end

--[=[
	@tag utility
	@since v0.3.0 
	Checks whether a given instance is a valid double lightsaber hilt section.
	Returns a message indicating why it isn't, if it isn't.
]=]
function ImportHilt.IsDoubleImportedHiltSection(instance: Instance): (boolean, string?)
	local hasDoubleName = ImportHilt.HasDoubleName(instance)
	local pass, message = ImportHilt.IsImportedLightsaberSection(instance)

	if not hasDoubleName then
		return false, `Name does not include "{ImportData.doubleGripSuffix}"`
	else
		return pass, message
	end
end

--[=[
	@tag utility
	@since v0.3.1
	Checks whether a given instance is a valid double lightsaber hilt section.
	Returns a message indicating why it isn't, if it isn't.
]=]
function ImportHilt.IsStaffImportedHiltSection(instance: Instance): (boolean, string?)
	local hasDoubleName = ImportHilt.HasStaffName(instance)
	local pass, message = ImportHilt.IsImportedLightsaberSection(instance)

	if not hasDoubleName then
		return false, `Name does not include "{ImportData.staffSuffix}"`
	else
		return pass, message
	end
end

--[=[
	@tag utility
	@since v0.3.0
	Checks whether a given instance is a valid lightsaber hilt section (emitter, grip, etc)
	Returns a message indicating why it isn't, if it isn't.
]=]
function ImportHilt.IsImportedLightsaberSection(instance: Instance): (boolean, string?)
	local sectionCheck = t.instanceIsA("Model", {
		root = t.instanceIsA("BasePart"),
		details = t.instanceIsA("Model"),
	})
	return sectionCheck(instance)
end

--[=[
	@tag utility
	@since v0.3.0
	Filters an array of Instances for only the ones that can be imported by the module.
]=]
function ImportHilt.FilterSelectionForImportableModels(selection: { Instance }): { Instance }
	return Llama.List.filter(selection, ImportHilt.IsImportableModel)
end

--[=[
	@tag utility
	@since v0.3.0
	Filters an array of Instances for only the ones that are already imported.
]=]
function ImportHilt.FilterSelectionForImportedModels(selection: { Instance }): { Instance }
	return Llama.List.filter(selection, ImportHilt.IsImportedLightsaberModel)
end

return ImportHilt
