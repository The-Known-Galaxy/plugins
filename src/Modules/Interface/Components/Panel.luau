--[=[
	@class Panel
	@tag Component 
	@since v0.3.0 

	Generic panel with a transparent background and rounded border.

	Meant for visually grouping elements.
]=]
local InterfaceConfig = require(script.Parent.Parent.InterfaceConfig)
local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement
--[=[
	@interface Props
	@within Panel
	.size UDim2?
	.position UDim2?
	.anchorPoint Vector2?
	.layoutOrder number?
	.children any?
]=]
export type Props = {
	size: UDim2?,
	position: UDim2?,
	anchorPoint: Vector2?,
	layoutOrder: number?,
	children: any?,
}

local DEFAULT_PROPS: Props = {
	size = UDim2.new(1, 0, 1, 0),
	position = UDim2.new(0.5, 0, 0.5, 0),
	anchorPoint = Vector2.new(0.5, 0.5),
	layoutOrder = 1,
}

local function Panel(props: Props)
	props = Llama.Dictionary.merge(DEFAULT_PROPS, props)

	return e("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = props.anchorPoint,
		Position = props.position,
		Size = props.size,
		LayoutOrder = props.layoutOrder,
	}, {
		Stroke = e("UIStroke", {
			Enabled = true,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = InterfaceConfig.Theme.Colours.Accent,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = 2.5,
			Transparency = 0,
		}),
		Corner = e("UICorner", {
			CornerRadius = InterfaceConfig.Theme.CornerRadius,
		}),
	}, props.children)
end

return Panel
