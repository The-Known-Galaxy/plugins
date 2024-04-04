local ImportData = require(script.Parent.Parent.ImportData)
local Configurations = {}

function Configurations.MakePrimaryHiltPart(part: BasePart): ()
	part:SetAttribute(ImportData.attributes.primaryHiltPart, true)
	part.Material = ImportData.basePartMaterial
	part.Color = ImportData.primaryPartColour

	part:SetAttribute(ImportData.attributes.fixedHiltPart, nil)
	part:SetAttribute(ImportData.attributes.crystalHiltPart, nil)
end

function Configurations.MakeFixedHiltPart(part: BasePart): ()
	part:SetAttribute(ImportData.attributes.fixedHiltPart, true)
	part.Material = ImportData.basePartMaterial
	part.Color = ImportData.basePartColour

	part:SetAttribute(ImportData.attributes.primaryHiltPart, nil)
	part:SetAttribute(ImportData.attributes.crystalHiltPart, nil)
end

function Configurations.MakeCrystalPart(part: BasePart): ()
	part:SetAttribute(ImportData.attributes.crystalHiltPart, true)
	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255, 255, 255)
end

return Configurations
