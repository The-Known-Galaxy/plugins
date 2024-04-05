--[=[
	@class MaterialManager
	@since v0.3.0 
	
	Handles all logic related to applying lightsaber hilt materials to imported hilt sets, and managing material previews on hilt models.
]=]
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local TweenService = game:GetService("TweenService")

local ImportData = require(script.Parent.ImportData)
local HiltMaterials = require(script.Parent.Parent.Parent.Modules.Data.Materials.HiltMaterials)

local MATERIAL_CHANGE_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)
local MATERIAL_PREVIEW_ATTRIBUTE = "MaterialPreviewApplied"

local MaterialManager = {}

--[=[
	@since v0.3.0
	Applies a material with the given name (must be its immutable internal name) to the given [BasePart] and its descendants, or a list of [BasePart]s and their descendants.
	Optionally, animates this transition for extra visual flair, smoothly.
]=]
function MaterialManager.ApplyHiltMaterialToParts(
	parts: { Instance } | Instance,
	materialName: string?,
	animate: boolean
)
	local color = nil
	local material = ImportData.basePartMaterial
	if materialName then
		color = HiltMaterials.materials[materialName].color
		material = HiltMaterials.materials[materialName].material or Enum.Material.Metal
	end

	local function recolor(hiltDescendant: BasePart)
		local chosenColor = if color
			then color
			else if hiltDescendant:GetAttribute(ImportData.attributes.primaryHiltPart)
				then ImportData.primaryPartColour
				else ImportData.basePartColour
		if hiltDescendant:GetAttribute(ImportData.attributes.primaryHiltPart) ~= nil then
			if animate then
				local tween
				tween = TweenService:Create(hiltDescendant, MATERIAL_CHANGE_TWEEN_INFO, {
					Color = chosenColor,
				})
				tween:Play()
			else
				hiltDescendant.Color = chosenColor
			end

			hiltDescendant.Material = material
		end
	end

	local function applyToInstanceDescendants(instance: Instance)
		for _, hiltDescendant in pairs(instance:GetDescendants()) do
			if hiltDescendant:IsA("BasePart") then
				recolor(hiltDescendant)
			end
		end
	end

	if typeof(parts) == "table" then
		for _, part in parts do
			applyToInstanceDescendants(part)
		end
	else
		applyToInstanceDescendants(parts)
	end
end

--[=[
	@tag utility
	@since v0.3.0
	Checks whether a given model has a material preview applied.
]=]
function MaterialManager.ModelHasMaterialPreview(instance: Model): boolean
	return instance:GetAttribute(MATERIAL_PREVIEW_ATTRIBUTE) ~= nil
end

--[=[
	@tag utility
	@since v0.3.0
	Checks whether a given model has a material preview of a specific material applied.
]=]
function MaterialManager.ModelHasMaterialPreviewSpecific(instance: Model, materialName: string)
	return instance:GetAttribute(MATERIAL_PREVIEW_ATTRIBUTE) == materialName
end

--[=[
	@since v0.3.0
	Toggles the material preview of a given model.
	Assumes the given model is a valid, imported lightsaber hilt.
	Refer to [ImportHilt.IsImportedLightsaberModel] for a way to check this condition.

	Creates a change history log (so that you can undo the operation), unless explicitly specified not to.
]=]
function MaterialManager.ToggleMaterialPreview(instance: Model, materialName: string, makeChangeHistoryLog: boolean?)
	if makeChangeHistoryLog == true or makeChangeHistoryLog == nil then
		ChangeHistoryService:SetWaypoint("ApplyMaterialPreview")
	end

	if MaterialManager.ModelHasMaterialPreviewSpecific(instance, materialName) then
		MaterialManager.ApplyHiltMaterialToParts(instance, nil, false)
		instance:SetAttribute(MATERIAL_PREVIEW_ATTRIBUTE, nil)
	else
		MaterialManager.ApplyHiltMaterialToParts(instance, materialName, false)
		instance:SetAttribute(MATERIAL_PREVIEW_ATTRIBUTE, materialName)
	end
end

--[=[
	@since v0.3.0
	Bulk toggles the material preview for a selection of models.
	Creates a change history log, so that you can undo this operation.
]=]
function MaterialManager.ToggleMaterialPreviewForSelection(selection: { Instance }, materialName: string)
	ChangeHistoryService:SetWaypoint("ApplyMaterialPreview")
	for _, instance in selection do
		MaterialManager.ToggleMaterialPreview(instance, materialName, false)
	end
end

return MaterialManager
