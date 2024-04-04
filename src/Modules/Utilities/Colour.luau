--[=[
	@class Colour

	Various advanced operations with colours.
]=]

local Colour = {}

--[=[
	@since v0.3.0
	Inverts a colour - useful for turning light to dark.  
]=]
function Colour.Inverse(colour: Color3): Color3
	return Color3.new(1 - colour.R, 1 - colour.G, 1 - colour.B)
end

return Colour
