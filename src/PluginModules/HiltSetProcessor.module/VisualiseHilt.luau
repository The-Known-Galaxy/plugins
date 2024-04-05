--[=[
	@class VisualiseHilt
	
	Provides visaulisation methods for well-formed lightsaber hilts.
]=]

local ImportData = require(script.Parent.ImportData)
local Logger = require(script.Parent.Parent.Parent.Modules.Logger)

local VisualiseHilt = {}

local VISUALISATION_FOLDER_NAME = "HiltVisualisations"
local VISUALISATION_COLOUR = Color3.fromRGB(255, 0, 0)

--[=[
	@since v0.3.0
	Visualises all the roots of the models in the selection of models.
]=]
function VisualiseHilt.VisualiseRootsInSelection(selection: { Model }): ()
	for _, model in selection do
		VisualiseHilt.VisualiseRoots(model)
	end
end

--[=[
	@since v0.3.0
	Visualises the roots of a given lightsaber.
	Helpful in debugging how the player might end up holding the lightsaber. 
	Assumes the given model is a well-formed lightsaber model.
]=]
function VisualiseHilt.VisualiseRoots(model: Model): ()
	if VisualiseHilt.VisualisationsExistForSpecificHilt(model) then
		return
	end

	local roots: { BasePart } = {}
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("BasePart") and descendant.Name == ImportData.rootPartName then
			table.insert(roots, descendant)
		end
	end

	for _, root in roots do
		VisualiseHilt._createRootPartVisual(root)
	end
end

function VisualiseHilt.VisualisationsExistForSpecificHilt(hilt: Model): boolean
	if VisualiseHilt.VisualisationsExist() then
		for _, visual in VisualiseHilt._getVisualisationFolder():GetChildren() do
			if visual.Name:find(hilt.Name) then
				return true
			end
		end
	end
	return false
end

--[=[
	@since v0.3.0
	Checks whether any visualisations currently exist in the studio.
]=]
function VisualiseHilt.VisualisationsExist(): boolean
	local existingFolder = workspace:FindFirstChild(VISUALISATION_FOLDER_NAME)
	if existingFolder then
		if existingFolder:IsA("Folder") then
			if #existingFolder:GetChildren() > 0 then
				return true
			end
		end
	end
	return false
end

--[=[
	@since v0.3.0 
	Clears all visualisations that exist.
	Assumes visualisations exist.
	Whether they exist can be checked with [VisualiseHilt.VisualisationsExist].
]=]
function VisualiseHilt.ClearAllVisualisations(): ()
	VisualiseHilt._getVisualisationFolder():Destroy()
end

--[=[
	@private
	@since v0.3.0 
	Creates a visualisation of a given root [BasePart] - coloured in, half-transparent bounding box.
]=]
function VisualiseHilt._createRootPartVisual(rootPart: BasePart): ()
	local parentSection = rootPart.Parent -- grip, emitter, etc

	-- getting bounding box
	local orientation, size = VisualiseHilt._getSelectionBoundingBox({ rootPart })

	local rootVisualisation = Instance.new("Part")
	rootVisualisation.Name = `{parentSection.Parent.Name}_root_visual`
	rootVisualisation.Size = size
	rootVisualisation.CFrame = orientation
	rootVisualisation.CanCollide = false
	rootVisualisation.Anchored = true
	rootVisualisation.CanQuery = false
	rootVisualisation.Locked = true -- shouldn't be able to select it
	rootVisualisation.Transparency = 0.5
	rootVisualisation.Color = VISUALISATION_COLOUR
	rootVisualisation.Parent = VisualiseHilt._getVisualisationFolder()
end

--[=[
	@private
	@since v0.3.0
	Gets the bounding box of a selection by cloning the selection, putting it into a model, and getting the bounding box of that. 
]=]
function VisualiseHilt._getSelectionBoundingBox(selection: { BasePart }): (CFrame, Vector3)
	local newModel = Instance.new("Model")
	for _, object in selection do
		object:Clone().Parent = newModel
	end

	newModel.Parent = workspace -- i haven't tested if you can get a bounding box without parenting to workspace, but to be safe im doing this
	local orientation, size = newModel:GetBoundingBox()
	newModel:Destroy()

	return orientation, size
end

--[=[
	@private
	@since v0.3.0 
	Gets the visualisation folder from the workspace, and creates it if it doesn't exist.
]=]
function VisualiseHilt._getVisualisationFolder(): Folder
	local existingFolder = workspace:FindFirstChild(VISUALISATION_FOLDER_NAME)
	if existingFolder ~= nil then
		if existingFolder:IsA("Folder") then
			return existingFolder
		end

		Logger.Warn(
			`Destroying [{existingFolder:GetFullName()}] since it's supposed to be a visualisation folder, but isn't a folder.`
		)
		existingFolder:Destroy()
	end

	-- creating a new folder
	local newFolder = Instance.new("Folder")
	newFolder.Name = VISUALISATION_FOLDER_NAME
	newFolder.Parent = workspace

	return newFolder
end

return VisualiseHilt
