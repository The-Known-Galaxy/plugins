--[=[
    @class ImportHilt
    
    Original code by [Nidoxs](https://github.com/Nidoxs).
    Refactored and improved by [ShadowEngineer](https://github.com/ShadowEngineer).
]=]
local SelectionService = game:GetService("Selection")

local NO_SELECTION_ERROR = "You need to select something before running the import hilt function!"
local INVALID_SELECTION_ERROR = "Selection at (%s) was not a model. Setup has been skipped for this selection."
local DETAIL_NAME = "%s_%s_detail%s_%d"
local INVALID_CHILDREN_ERROR =
	"Invalid child (%s<%s>) found in (%s). Remove anything that isn't a BasePart of MeshPart and try again. Setup has been skipped for this selection."

-- in global space
local CLONE_OFFSET = Vector3.new(0, 3, 0)

local ImportData = require(script.Parent.ImportData)
local Logger = require(script.Parent.Parent.Parent.Modules.Logger)

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
	```

	Expects an Instance of the form:
	```
	Model: Lightsaber Name
		{ BasePart }
	```
]=]
function ImportHilt.Import()
	local selection = SelectionService:Get()
	if not (#selection > 0) then
		Logger.Warn(NO_SELECTION_ERROR)
		return
	end

	local importedInstances = {}

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
		local newInstance = selectedInstance:Clone()
		newInstance.Parent = selectedInstance.Parent
		newInstance:PivotTo(newInstance:GetPivot() + CLONE_OFFSET)

		-- this might be put in some names, so removing
		local setName = newInstance.Name:lower():gsub("_lightsaber", "")

		local setModel = Instance.new("Model")
		setModel.Name = setName

		local longHandleModel = Instance.new("Model")
		longHandleModel.Name = setName .. "_double_grip"

		local longDetailsModel = Instance.new("Model")
		longDetailsModel.Name = "details"

		local doubleRoot
		local doubleGripDetailCount = 0

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

				if nameMatchesKeyWords(childName, keywordsForSection) then
					-- checking for what kind of part it is by searching for keyword matches against the part's name
					local isPrimaryPart = nameMatchesKeyWords(childName, ImportData.keywords.primary)
					local isRootPart = nameMatchesKeyWords(childName, ImportData.keywords.root)
					local isDoubleRoot = nameMatchesKeyWords(childName, ImportData.keywords.doubleGrip)
					local isCrystalPart = nameMatchesKeyWords(childName, ImportData.keywords.crystal)

					if isPrimaryPart or isRootPart then
						child:SetAttribute(ImportData.attributes.primaryHiltPart, true)
						child.Color = ImportData.primaryPartColour
					else
						child:SetAttribute(ImportData.attributes.fixedHiltPart, true)
					end

					if isCrystalPart then
						child:SetAttribute(ImportData.attributes.crystalHiltPart, true)
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
					elseif isCrystalPart then
						partCategory = "(crystal)"
					end

					-- if a root part for the given section does not yet exist, then set it up as a root part if it matches root part keywords
					-- everything that isn't a root part is detail
					if isDoubleRoot then
						if not doubleRoot and isRootPart then
							child.Name = "root"
							child.Parent = longHandleModel
							doubleRoot = child
							longHandleModel.PrimaryPart = child
						else
							doubleGripDetailCount += 1

							child.Name = DETAIL_NAME:format(setName, sectionName, partCategory, detailCount)
							child.Parent = longDetailsModel
						end
					else
						if not rootForSection and isRootPart then
							child.Name = "root"
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
		longHandleModel.Parent = newInstance
		longDetailsModel.Parent = longHandleModel
		newInstance.Name = setName

		table.insert(importedInstances, newInstance)
	end

	SelectionService:Set(importedInstances)
end

return ImportHilt
