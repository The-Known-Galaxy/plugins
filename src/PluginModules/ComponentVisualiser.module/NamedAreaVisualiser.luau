--[=[
    @class NamedAreaVisualiser
    
    Handles all backend functionality to visualising named areas.
]=]
local CollectionService = game:GetService("CollectionService")

--[=[
    @type VisualsEnabled boolean | "partial"
    @within NamedAreaVisualiser
    A type representing the visualisation state of a given part, named area, or the entire map.
]=]
export type VisualsEnabled = boolean | "partial"

local NAMED_AREA_TAG = "NamedArea"
local WORLD_REGION_TAG = "WorldRegion"

local VISUAL_TRANSPARENCY = 0.7
local VISUAL_COLOUR = Color3.fromRGB(255, 0, 0)

local NamedAreaVisualiser = {}

--[=[
    @since v0.4.0
    @tag utility
    Utility for getting all valid `NamedArea` objects. Checks if they are valid `WorldRegion`s too.
]=]
function NamedAreaVisualiser.GetValidNamedAreas(): { Model }
	local taggedObjects = CollectionService:GetTagged(NAMED_AREA_TAG)
	local namedAreas = {}
	for _, object in taggedObjects do
		if object:IsA("Model") and object:HasTag(WORLD_REGION_TAG) then
			table.insert(namedAreas, object)
		end
	end

	return namedAreas
end

--[=[
    @since v0.4.0
    @tag utility
    Utility for getting all the [BasePart] descendants of a given instance.
]=]
function NamedAreaVisualiser.GetBasePartDescendants(instance: Instance): { BasePart }
	local basePartDescendants = {}
	for _, descendant in instance:GetDescendants() do
		if descendant:IsA("BasePart") then
			table.insert(basePartDescendants, descendant)
		end
	end
	return basePartDescendants
end

--[=[
    @since v0.4.0
    Whether visualisations are fully, partially or not at all toggled on a given part.
]=]
function NamedAreaVisualiser.VisualsEnabledOnPart(part: BasePart): VisualsEnabled
	if part.Transparency == 1 then
		return false
	end

	-- since floating point error exists in ROBLOX Studio numerical properties...
	local transparencyMatch = math.abs(part.Transparency - VISUAL_TRANSPARENCY) < 0.0001
	local coloursMatch = part.Color == VISUAL_COLOUR

	-- not checking Locked or Material property since they don't matter
	if coloursMatch and transparencyMatch then
		return true
	elseif coloursMatch or transparencyMatch then
		return "partial"
	else
		return false
	end
end

--[=[
    @within NamedAreaVisualiser
    @private
    @since v0.4.0

    Runs a visualisation predicate on all the given objects.
    Generic function to increase DRY.
]=]
local function countVisuals<V>(objects: { V }, predicate: (V) -> VisualsEnabled): VisualsEnabled
	local parts = objects
	local numTotal = #parts
	local numTrue = 0
	local numPartial = 0

	for _, part in parts do
		local result = predicate(part)
		if result == true then
			numTrue += 1
		elseif result == "partial" then
			numPartial += 1
		end
	end

	if numTrue == numTotal then
		return true
	elseif numPartial > 0 then
		return "partial"
	else
		return false
	end
end

--[=[
    @since v0.4.0
    Whether visualisations are fully, partially or not at all toggled on a given Named Area.
]=]
function NamedAreaVisualiser.VisualsEnabledOnNamedArea(namedArea: Model): VisualsEnabled
	return countVisuals(NamedAreaVisualiser.GetBasePartDescendants(namedArea), NamedAreaVisualiser.VisualsEnabledOnPart)
end

--[=[
    @since v0.4.0
    Whether visualisations are fully, partially or not at all toggled on all the existing NamedAreas.
]=]
function NamedAreaVisualiser.AreVisualsEnabled(): VisualsEnabled
	return countVisuals(NamedAreaVisualiser.GetValidNamedAreas(), NamedAreaVisualiser.VisualsEnabledOnNamedArea)
end

--[=[
    @since v0.4.0
    Toggles visualisations on all named areas.
]=]
function NamedAreaVisualiser.ToggleVisuals(shouldVisualise: boolean)
	local namedAreas = NamedAreaVisualiser.GetValidNamedAreas()
	for _, area in namedAreas do
		NamedAreaVisualiser.ToggleOnNamedArea(area, shouldVisualise)
	end
end

--[=[
    @since v0.4.0
    Toggles visualisations on a given named area, altering Locked, Color and Transparency properties as needed.
]=]
function NamedAreaVisualiser.ToggleOnNamedArea(object: Model, shouldVisualise: boolean)
	local basePartDescendants = NamedAreaVisualiser.GetBasePartDescendants(object)

	for _, descendant in basePartDescendants do
		descendant.Locked = not shouldVisualise
		descendant.Transparency = if shouldVisualise then VISUAL_TRANSPARENCY else 1
		descendant.Color = VISUAL_COLOUR
		descendant.Material = Enum.Material.SmoothPlastic
	end
end

return NamedAreaVisualiser
