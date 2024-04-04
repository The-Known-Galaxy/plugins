--[=[
	@tag Component 
	@class ScrollingList
	@since v0.3.0
	A generic panel where all its children will be placed inside a [ScrollingFrame] for scrolling.
	Can scroll in either direction.

	Scrollbar hides itself after some seconds of inactivity AND not hovering over the list - as a nice UX touch.
	Scrollbar is also invisible when the content size is less than the canvas size (in the scroll direction).
]=]
local ButtonMask = require(script.Parent.ButtonMask)
local Padding = require(script.Parent.Padding)
local InterfaceConfig = require(script.Parent.Parent.InterfaceConfig)
local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)
local ReactSpring = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.ReactSpring)

local e = React.createElement
--[=[ 
	@interface Props
	@within ScrollingList
	.elements { [any]: any } -- the dictionary of React Nodes to give it for rendering inside the list. Should ideally have stable keys
	.listPadding UDim -- the padding between each list element
	.startPadding UDim? -- the padding at the start of the list, useful if certain elements go outside their root size
	.endPadding UDim? -- the padding at the end of the list, useful for the same reason as startPadding
	.leftPadding UDim? -- the padding to the left of the list
	.rightPadding UDim? -- the padding to the right of the list
	.canvasIgnoresScrollBar boolean? -- whether the canvas size should not react to the scrollbar size changing
	.listSortOrder Enum.SortOrder? -- how the list should sort its elements. Custom ordering is not yet supported
	.scrollDirection Enum.FillDirection? -- which direction the list should flow in. FillDirection is used since it's semantic to write and doesn't support XY scrolling

	.native { [string]: any }?
	.children any?

	It should be noted that all padding props should **only use the offset value**. Undefined behaviour will occur when the [UDim.Scale] property is used.
]=]
export type Props = {
	elements: { [any]: any },
	listPadding: UDim,
	startPadding: UDim?,
	endPadding: UDim?,
	leftPadding: UDim?,
	rightPadding: UDim?,
	canvasIgnoresScrollBar: boolean?,
	listSortOrder: Enum.SortOrder?,
	scrollDirection: Enum.FillDirection?,

	native: { [string]: any }?,
	children: any?,
}

local DEFAULT_PROPS: Props = {
	elements = {},
	listPadding = UDim.new(0, 5),
	startPadding = UDim.new(0, 0),
	endPadding = UDim.new(0, 0),
	leftPadding = UDim.new(0, 0),
	rightPadding = UDim.new(0, 0),
	canvasIgnoresScrollBar = false,
	listSortOrder = Enum.SortOrder.LayoutOrder,
	scrollDirection = Enum.FillDirection.Vertical,
	native = {
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.new(1, 0, 0, 100),
		Position = UDim2.new(0.5, 0, 0, 0),
		LayoutOrder = 1,
	},
}
local INACTIVITY_TIME = 3

local function ScrollingList(props: Props)
	props.native = Llama.Dictionary.merge(DEFAULT_PROPS.native, props.native)
	props = Llama.Dictionary.merge(DEFAULT_PROPS, props)

	local canvasSize, setCanvasSize = React.useState(UDim2.new(0, 100, 0, 100))
	local absoluteCanvasSize, setAbsoluteCanvasSize = React.useState(Vector2.new(100, 100))
	local absoluteContentSize, setAbsoluteContentSize = React.useState(Vector2.new(100, 100))
	local hovered, setHovered = React.useState(false)
	local inactive, setInactive = React.useState(false)

	local scrollDirection = React.useMemo(function()
		if props.scrollDirection == Enum.FillDirection.Vertical then
			return Enum.ScrollingDirection.Y
		else
			return Enum.ScrollingDirection.X
		end
	end, { props.scrollDirection })

	React.useEffect(function()
		if hovered == false then
			local thread = task.delay(INACTIVITY_TIME, function()
				setInactive(true)
			end)

			return function()
				task.cancel(thread)
			end
		end

		setInactive(false)
		return nil
	end, { hovered })

	local scrollingEnabled = React.useMemo(function()
		if inactive then
			return false
		end

		if props.scrollDirection == Enum.FillDirection.Vertical then
			return absoluteContentSize.Y > absoluteCanvasSize.Y
		else
			return absoluteContentSize.X > absoluteCanvasSize.X
		end
	end, { absoluteContentSize, absoluteCanvasSize, props.scrollDirection, inactive })

	local styles = ReactSpring.useSpring({
		scrollBarThickness = if scrollingEnabled then 8 else 0,
		config = InterfaceConfig.Springs.Snappy,
	})

	local contentSizeChanged = React.useCallback(function(listLayout: UIListLayout)
		local nativeProps = props.native
		local intendedSize: UDim2 = nativeProps.Size
		local startPadding = props.startPadding
		local endPadding = props.endPadding
		local startAndEndPadding = startPadding.Offset + endPadding.Offset
		local modifiedAbsoluteContentSize = Vector2.new(
			listLayout.AbsoluteContentSize.X + startAndEndPadding,
			listLayout.AbsoluteContentSize.Y + startAndEndPadding
		)

		if props.scrollDirection == Enum.FillDirection.Vertical then
			setCanvasSize(UDim2.new(intendedSize.Width, UDim.new(0, modifiedAbsoluteContentSize.Y)))
		else
			setCanvasSize(UDim2.new(UDim.new(0, modifiedAbsoluteContentSize.X), intendedSize.Height))
		end

		setAbsoluteContentSize(modifiedAbsoluteContentSize)
	end, { props.scrollDirection, props.startPadding, props.endPadding })

	local absoluteSizeChanged = React.useCallback(function(frame: ScrollingFrame)
		setAbsoluteCanvasSize(frame.AbsoluteSize)
	end, {})

	-- ensuring that the canvas shrinks when the scroll bar expands
	local scrollBarThicknessMappedToCanvasSize = styles.scrollBarThickness:map(function(value)
		if props.canvasIgnoresScrollBar then
			return canvasSize
		end

		if props.scrollDirection == Enum.FillDirection.Vertical then
			return UDim2.new(UDim.new(canvasSize.X.Scale, canvasSize.X.Offset - value), canvasSize.Height)
		else
			return UDim2.new(canvasSize.Width, UDim.new(canvasSize.Y.Scale, canvasSize.Y.Offset - value))
		end
	end)

	return e("Frame", {
		BackgroundTransparency = 1,
		Size = (props.native :: any).Size,
		LayoutOrder = (props.native :: any).LayoutOrder,
		[React.Change.AbsoluteSize] = absoluteSizeChanged,
	}, {
		ButtonFunctionality = e(
			ButtonMask,
			{
				onHoverIn = function()
					setHovered(true)
				end,
				onHoverOut = function()
					setHovered(false)
				end,
				native = {
					Size = scrollBarThicknessMappedToCanvasSize:map(function(size: UDim2)
						-- ensuring that the button mask also shrinks with scrollbar size
						-- because otherwise the mask is over the scrollbar and you can't click the scrollbar to scroll
						if props.scrollDirection == Enum.FillDirection.Vertical then
							return UDim2.new(size.Width, UDim.new(1, 0))
						else
							return UDim2.new(UDim.new(1, 0), size.Height)
						end
					end),
				},
			} :: ButtonMask.Props
		),
		ScrollableList = e(
			"ScrollingFrame",
			Llama.Dictionary.merge(props.native, {
				Size = UDim2.new(1, 0, 1, 0),
				ScrollingEnabled = scrollingEnabled,
				BackgroundTransparency = 1,
				ScrollingDirection = scrollDirection,
				CanvasSize = scrollBarThicknessMappedToCanvasSize,
				BorderSizePixel = 0,
				ScrollBarImageColor3 = InterfaceConfig.Theme.Colours.Accent,
				ScrollBarImageTransparency = 0,
				ScrollBarThickness = styles.scrollBarThickness,
				TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
				BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
				MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
				HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
				ElasticBehavior = Enum.ElasticBehavior.Always,
			}),
			{
				Layout = e("UIListLayout", {
					Padding = props.listPadding,
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = props.listSortOrder,
					[React.Change.AbsoluteContentSize] = contentSizeChanged,
				}),
				Padding = e(
					Padding,
					{
						[if props.scrollDirection == Enum.FillDirection.Horizontal then "left" else "top"] = props.startPadding,
						[if props.scrollDirection == Enum.FillDirection.Horizontal then "right" else "bottom"] = props.endPadding,
						[if props.scrollDirection == Enum.FillDirection.Horizontal then "bottom" else "left"] = props.leftPadding,
						[if props.scrollDirection == Enum.FillDirection.Horizontal then "top" else "right"] = props.rightPadding,
					} :: Padding.Props
				),
				Elements = e(React.Fragment, nil, props.elements),
			},
			props.children
		),
	})
end

return ScrollingList
