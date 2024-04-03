--[=[
	@class Text
	@tag Component
	@since v0.3.0  

	Generic text display component.
	Pretty much a wrapper around [TextLabel].
	Size constrained to minimum `32x10`.
]=]
local InterfaceConfig = require(script.Parent.Parent.InterfaceConfig)
local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)
local TextFormat = require(script.Parent.Parent.Parent.Utilities.TextFormat)

local e = React.createElement
--[=[
    @type Style "normal" | "title" | "subtitle"
    @within Text
]=]
type Style = "normal" | "title" | "subtitle"
type TextConfig = {
	font: Enum.Font,
	fontSize: number,
	fontWeight: Enum.FontWeight,
	fontColour: Color3,
}
--[=[
	@interface Props
	@within Text
	.style Style? -- configures font styling
	.italics boolean? -- to format as italics
	.bold boolean? -- to format as bold
	.text string? -- the actual text to display itself
	.autoSize boolean? -- whether the text lable should resize in either axis
	.autoSizeDirection Enum.FillDirection? -- which axis to resize on if autoSize is true

	.native { [string]: any }?
	.children any?
]=]
export type Props = {
	style: Style?,
	italics: boolean?,
	bold: boolean?,
	text: string?,
	autoSize: boolean?,
	autoSizeDirection: Enum.FillDirection?,

	native: { [string]: any }?,
	children: any?,
}

local STYLE_TO_CONFIG: { [Style]: TextConfig } = {
	["title"] = {
		font = Enum.Font.Merriweather,
		fontSize = 28,
		fontWeight = Enum.FontWeight.Medium,
		fontColour = InterfaceConfig.Theme.Colours.Primary,
	},
	["subtitle"] = {
		font = InterfaceConfig.Theme.Font,
		fontSize = 24,
		fontWeight = Enum.FontWeight.Light,
		fontColour = InterfaceConfig.Theme.Colours.Tertiary,
	},
	["normal"] = {
		font = InterfaceConfig.Theme.Font,
		fontSize = 16,
		fontWeight = Enum.FontWeight.Regular,
		fontColour = InterfaceConfig.Theme.Colours.Text,
	},
}

local DEFAULT_PROPS: Props = {
	style = "normal",
	italics = false,
	bold = false,
	text = "",
	autoSize = false,
	autoSizeDirection = Enum.FillDirection.Vertical,
	native = {
		Size = UDim2.new(0, 50, 0, 20),
	},
}

local function Text(props: Props)
	props.native = Llama.Dictionary.merge(DEFAULT_PROPS.native, props.native)
	props = Llama.Dictionary.merge(DEFAULT_PROPS, props)

	-- technically this memo doesn't need to exist but static analysis complains at types if it doesn't
	local defaultElementSize = React.useMemo(function()
		if props.native then
			return props.native.Size
		end
		return
	end, { props.native })

	local elementSize, setElementSize = React.useBinding(defaultElementSize)

	local text = React.useMemo(function()
		local formattedText = props.text
		if props.bold then
			formattedText = TextFormat.Bold(formattedText)
		end
		if props.italics then
			formattedText = TextFormat.Italics(formattedText)
		end
		return formattedText
	end, { props.text, props.bold, props.italics })

	local textConfig: TextConfig = React.useMemo(function()
		return STYLE_TO_CONFIG[props.style :: Style]
	end, { props.style })

	local font = React.useMemo(function()
		local customFont = Font.fromEnum(textConfig.font)
		customFont.Weight = textConfig.fontWeight
		return customFont
	end, { textConfig.font, textConfig.fontWeight })

	local changeTextBounds = React.useCallback(function(instance: TextLabel)
		local oldSize: UDim2 = elementSize:getValue()
		if props.autoSizeDirection == Enum.FillDirection.Horizontal then
			setElementSize(UDim2.new(UDim.new(0, instance.TextBounds.X), oldSize.Height))
		else
			setElementSize(UDim2.new(oldSize.Width, UDim.new(0, instance.TextBounds.Y)))
		end
	end, { props.autoSizeDirection, defaultElementSize })

	return e(
		"TextLabel",
		Llama.Dictionary.merge(props.native, {
			Size = elementSize,
			BackgroundTransparency = 1,
			FontFace = font,
			RichText = true,
			Text = text,
			TextSize = textConfig.fontSize,
			TextWrapped = true,
			TextColor3 = textConfig.fontColour,
			[React.Change.TextBounds] = if props.autoSize then changeTextBounds else nil,
		}),
		{
			SizeConstraint = e("UISizeConstraint", {
				MinSize = Vector2.new(32, 10),
			}),
		},
		props.children
	)
end

return Text
