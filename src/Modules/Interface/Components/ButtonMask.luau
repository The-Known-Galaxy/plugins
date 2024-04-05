--[=[
	@class ButtonMask
	
	Non-stylised invisible text button.
	Simply creates a button on top of another component that implements hover and click detection.
	Useful when you don't want a full stylised button, but do want an element to behave differently when hovered or clicked on.
]=]

local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement
--[=[
	@interface Props
	@within ButtonMask
	.onActivate () -> ()
	.onHoverIn () -> ()
	.onHoverOut () -> ()

	.native { [string]: any }?
	.children any?
]=]
export type Props = {
	onActivate: () -> (),
	onHoverIn: () -> (),
	onHoverOut: () -> (),

	native: { [string]: any }?,
	children: any?,
}

local DEFAULT_PROPS: Props = {
	onActivate = function() end,
	onHoverIn = function() end,
	onHoverOut = function() end,
	native = {
		Size = UDim2.new(1, 0, 1, 0), -- by default it should cover the entire parent element
		ZIndex = 5, -- by default it should be higher than most other elements so that the button is actually triggered
	},
}

local function ButtonMask(props: Props)
	props.native = Llama.Dictionary.merge(DEFAULT_PROPS.native, props.native)
	props = Llama.Dictionary.merge(DEFAULT_PROPS, props)

	return e(
		"TextButton",
		Llama.Dictionary.merge(props.native, {
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = "",
			[React.Event.MouseButton1Click] = function()
				props.onActivate()
			end,
			[React.Event.MouseEnter] = function()
				props.onHoverIn()
			end,
			[React.Event.MouseLeave] = function()
				props.onHoverOut()
			end,
		})
	)
end

return ButtonMask
