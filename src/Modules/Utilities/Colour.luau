--[=[
	@class Colour

	Various advanced operations with colours.
]=]

local Colour = {}

--[=[
	@since v0.3.0
	Inverts a colour - useful for turning light to dark.
	Achieves this by inverting the R, G and B values of the colour - this achieves the effect of essentially "moving that colour to the opposite end of the colour wheel".
	Blue turns orange, green turns purple, red turns yellow, etc.
]=]
function Colour.Inverse(colour: Color3): Color3
	return Color3.new(1 - colour.R, 1 - colour.G, 1 - colour.B)
end

return Colour
