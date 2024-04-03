--[=[
	@class Padding
	@tag Component
	@since v0.3.0  

	[UIPadding] wrapper component.
	Provides an easier interface to create padding objects.
]=]

local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement
--[=[
	@interface Props
	@within Padding
	.all UDim? -- overrides all directions
	.horizontal UDim? -- overrides both left and right
	.vertical UDim? -- overrides both top and bottom
	.bottom UDim?
	.left UDim?
	.right UDim?
	.top UDim?

	.native { [string]: any }?
	.children any?
]=]
export type Props = {
	all: UDim?,
	horizontal: UDim?,
	vertical: UDim?,
	bottom: UDim?,
	left: UDim?,
	right: UDim?,
	top: UDim?,

	native: { [string]: any }?,
	children: any?,
}

local DEFAULT_PROPS: Props = {
	bottom = UDim.new(0, 0),
	left = UDim.new(0, 0),
	right = UDim.new(0, 0),
	top = UDim.new(0, 0),
}

local function Padding(props: Props)
	props = Llama.Dictionary.mergeDeep(DEFAULT_PROPS, props)

	local bottom = React.useMemo(function()
		if props.all then
			return props.all
		elseif props.vertical then
			return props.vertical
		else
			return props.bottom
		end
	end, { props.all, props.vertical, props.bottom })

	local left = React.useMemo(function()
		if props.all then
			return props.all
		elseif props.horizontal then
			return props.horizontal
		else
			return props.left
		end
	end, { props.all, props.horizontal, props.left })

	local right = React.useMemo(function()
		if props.all then
			return props.all
		elseif props.horizontal then
			return props.horizontal
		else
			return props.right
		end
	end, { props.all, props.horizontal, props.right })

	local top = React.useMemo(function()
		if props.all then
			return props.all
		elseif props.vertical then
			return props.vertical
		else
			return props.top
		end
	end, { props.all, props.vertical, props.top })

	return e(
		"UIPadding",
		Llama.Dictionary.merge(props.native, {
			PaddingBottom = bottom,
			PaddingLeft = left,
			PaddingRight = right,
			PaddingTop = top,
		}),
		props.children
	)
end

return Padding
