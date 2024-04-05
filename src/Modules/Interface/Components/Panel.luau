--[=[
	@class Panel
	@tag Component 
	@since v0.3.0 

	Generic panel with a transparent background and rounded border.
	Meant for visually grouping elements.

	Essentially a wrapper around [Frame].
	Size constrained to `40x40`.
]=]
local InterfaceConfig = require(script.Parent.Parent.InterfaceConfig)
local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement
--[=[
	@interface Props
	@within Panel
	.autoSize boolean? -- whether the text lable should resize in either axis
	.autoSizeDirection Enum.FillDirection? -- which axis to resize on if autoSize is true

	.native { [string]: any }?
	.children any?
]=]
export type Props = {
	autoSize: boolean?,
	autoSizeDirection: Enum.FillDirection?,

	native: { [string]: any }?,
	children: any?,
}

local DEFAULT_PROPS: Props = {
	autoSize = false,
	autoSizeDirection = Enum.FillDirection.Vertical,
	native = {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		LayoutOrder = 1,
	},
}

local function Panel(props: Props)
	props.native = Llama.Dictionary.merge(DEFAULT_PROPS.native, props.native)
	props = Llama.Dictionary.merge(DEFAULT_PROPS, props)

	local automaticSize, adjustedSize = React.useMemo(function()
		if props.autoSize then
			local oldSize: UDim2 = if props.native then props.native.Size else UDim.new()

			if props.autoSizeDirection == Enum.FillDirection.Horizontal then
				return Enum.AutomaticSize.X, UDim2.new(UDim.new(0, 0), oldSize.Height)
			else
				return Enum.AutomaticSize.Y, UDim2.new(oldSize.Width, UDim.new(0, 0))
			end
		else
			return Enum.AutomaticSize.None, nil
		end
	end, { props.autoSize, props.autoSizeDirection, props.native })

	return e(
		"Frame",
		Llama.Dictionary.merge(props.native, {
			BackgroundTransparency = 1,
			AutomaticSize = automaticSize,
			Size = adjustedSize,
		}),
		{
			SizeConstraint = e("UISizeConstraint", {
				MinSize = Vector2.new(40, 40),
			}),
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
		},
		props.children
	)
end

return Panel
