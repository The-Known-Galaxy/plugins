--[=[
	@class Button
	@tag Component 
	@since v0.3.0 
	
	Generic button implementation for all UI to use.
	Takes style themeing from [InterfaceConfig].
	Size constrained to `16x16`.

	Implements 3 styles:
	1. **Solid**: Solid-filled buttons, where hovering creates a white border and whitens the fill.
	2. **Outline**: Transparent buttons with a theme-coloured border, where hovering whitens the border and slightly whitens the fill and makes it opaque.
	3. **Text**: Transparent button with no border, where hovering slightly whitens the fill and makes it opaque.

	With 2 kinds:
	1. **Primary**: Uses the primary theme colour
	2. **Secondary**: Uses the secondary theme colour.
]=]
local InterfaceConfig = require(script.Parent.Parent.InterfaceConfig)
local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)
local ReactSpring = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.ReactSpring)

local e = React.createElement

--[=[ 
	@type Callback () -> ()
	@within Button
	
	Generic callback function.
]=]
type Callback = () -> ()
--[=[ 
	@interface Props
	@within Button
	.style "Solid" | "Outline" | "Text"
	.kind "Primary" | "Secondary"
	.active boolean? -- whether the button is active.
	.onActivate Callback? -- fires when the button is pressed with LMB
	.onHoverIn Callback? -- fires when the user enters hover on the button
	.onHoverOut Callback? -- fires when the user exits hover on the button
	.text string? -- the text to display when the button is active
	.disabledText string? -- the text to display when the button is NOT active
	.image string? -- image asset URL. If supplied, an image is shown instead of text

	.native { [string]: any }?
	.children any?
]=]
export type Props = {
	style: "Solid" | "Outline" | "Text",
	kind: "Primary" | "Secondary",
	active: boolean?,
	onActivate: Callback?,
	onHoverIn: Callback?,
	onHoverOut: Callback?,
	text: string?,
	disabledText: string?,
	image: string?,

	native: { [string]: any }?,
	children: any?,
}

local DEFAULT_PROPS: Props = {
	style = "Solid",
	kind = "Primary",
	active = true,
	text = "Button Text",
	disabledText = "Disabled",
	native = {
		Size = UDim2.new(0, 200, 0, 40),
	},
}
local BUTTON_BORDER_STROKE_WIDTH_PX = 3

local function Button(props: Props)
	props = Llama.Dictionary.mergeDeep(DEFAULT_PROPS, props)

	local isHovering, setIsHovering = React.useState(false)

	local styles = ReactSpring.useSpring({
		buttonHoverLerpAlpha = if isHovering and props.active then 1 else 0,
		config = InterfaceConfig.Springs.Snappy,
	})

	-- determing what type of button this is
	local isTextualButton, isImageButton = React.useMemo(function()
		local imageIsNil = props.image == nil
		return imageIsNil, not imageIsNil
	end, { props.image })

	-- means the whole button should be coloured this colour
	local solidFillButton = React.useMemo(function()
		return props.style == "Solid"
	end, { props.style })

	-- outline and text buttons should fill the button white on hover, and otherwise have it as transparent
	local fillOnlyOnHover = React.useMemo(function()
		return (props.style == "Outline" or props.style == "Text")
	end, { props.style })

	-- otherwise the button is transparent
	local buttonTransparency = React.useMemo(function()
		return if solidFillButton then 0 else 1
	end, { solidFillButton })

	-- determining button colour
	local buttonColour = React.useMemo(function()
		local colour: Color3 = InterfaceConfig.Theme.Colours[props.kind]
		if props.active then
			return colour
		else
			return colour:Lerp(Color3.fromHSV(360, 0, 0.2), 0.75)
		end
	end, { props.kind, props.active })

	-- remapping properties based on hover status and spring alpha
	local buttonColourMapped = styles.buttonHoverLerpAlpha:map(function(alpha)
		return buttonColour:Lerp(Color3.fromHSV(360, 0, 1), 0.5 * alpha)
	end)
	local buttonBorderSizeMapped = styles.buttonHoverLerpAlpha:map(function(alpha)
		return alpha * BUTTON_BORDER_STROKE_WIDTH_PX
	end)
	local buttonTransparencyMapped = styles.buttonHoverLerpAlpha:map(function(alpha)
		return (1 - alpha)
	end)

	-- choosing text to display
	local buttonText = React.useMemo(function()
		return if props.active then props.text else props.disabledText
	end, { props.active, props.text, props.disabledText })

	local buttonBackgroundColour = if solidFillButton then buttonColourMapped else Color3.fromHSV(360, 0, 0.5)

	return e(
		if isTextualButton then "TextButton" else "ImageButton",
		Llama.Dictionary.merge(props.native, {
			BackgroundTransparency = if fillOnlyOnHover then buttonTransparencyMapped else buttonTransparency,
			BackgroundColor3 = buttonBackgroundColour,
			BorderSizePixel = 0,
			AutoButtonColor = false,

			-- textual button exclusive
			Text = if isTextualButton then "" else nil,

			-- image button exclusive
			Image = if isImageButton then props.image else nil,
			ImageColor3 = if isImageButton then buttonBackgroundColour else nil,
			ScaleType = if isImageButton then Enum.ScaleType.Fit else nil,

			[React.Event.MouseButton1Click] = props.onActivate,
			[React.Event.MouseEnter] = function()
				setIsHovering(true)
				if props.onHoverIn then
					props.onHoverIn()
				end
			end,
			[React.Event.MouseLeave] = function()
				setIsHovering(false)
				if props.onHoverOut then
					props.onHoverOut()
				end
			end,
		}),
		{
			SizeConstraint = e("UISizeConstraint", {
				MinSize = Vector2.new(16, 16),
			}),
			Label = isTextualButton and e("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0.6, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Text = buttonText,
				RichText = true,
				TextColor3 = InterfaceConfig.Theme.Colours.Text,
				Font = InterfaceConfig.Theme.Font,
				TextScaled = true,
			}),
			Corner = e("UICorner", {
				CornerRadius = InterfaceConfig.Theme.CornerRadius,
			}),
			Stroke = e("UIStroke", {
				Enabled = true,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = if props.style == "Solid" then Color3.fromHSV(0, 0, 1) else buttonColourMapped,
				LineJoinMode = Enum.LineJoinMode.Round,
				Thickness = if props.style == "Solid"
					then buttonBorderSizeMapped
					elseif props.style == "Outline" then BUTTON_BORDER_STROKE_WIDTH_PX
					else 0,
				Transparency = 0,
			}),
		},
		props.children
	)
end

return Button
