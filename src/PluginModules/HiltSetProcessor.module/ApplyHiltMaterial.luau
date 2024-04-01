local TweenService = game:GetService("TweenService")

local HiltMaterials = require(script.Parent.Parent.Parent.Modules.Data.Materials.HiltMaterials)

local MATERIAL_CHANGE_TWEEN_INFO = TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)

local MaterialManager = {}

function MaterialManager.Apply(parts: { BasePart } | BasePart, materialName: string, animate: boolean)
	local color = HiltMaterials[materialName].color
	local material = HiltMaterials[materialName].material or Enum.Material.Metal

	local function recolor(hiltDescendant: BasePart)
		if hiltDescendant:GetAttribute("PrimaryHiltPart") ~= nil then
			if animate then
				local tween
				tween = TweenService:Create(hiltDescendant, MATERIAL_CHANGE_TWEEN_INFO, {
					Color = color,
				})
				tween:Play()
			else
				hiltDescendant.Color = color
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

return MaterialManager
