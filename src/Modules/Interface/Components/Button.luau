local InterfaceConfig = require(script.Parent.Parent.InterfaceConfig)
local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement

type Callback = () -> ()
export type Props = {
	style: "Solid" | "Outline" | "Text",
	kind: "Primary" | "Secondary",
	active: boolean?,

	size: UDim2?,
	position: UDim2?,
	anchorPoint: Vector2?,

	onActivate: Callback?,
	onHoverIn: Callback?,
	onHoverOut: Callback?,

	text: string?,
	disabledText: string?,
	image: string?,

	children: any?,
}

local DEFAULT_PROPS: Props = {
	style = "Solid",
	kind = "Primary",
	active = true,
	size = UDim2.new(0, 200, 0, 40),
	text = "Button Text",
	disabledText = "Disabled",
}

local function Button(props: Props)
	props = Llama.Dictionary.merge(DEFAULT_PROPS, props)

	local backgroundTransparency = React.useMemo(function()
		return if props.style == "Solid" or props.image then 0 else 1
	end, { props.style, props.image })

	local backgroundColour = React.useMemo(function()
		local colour: Color3 | nil = if props.style == "Solid" or props.image
			then InterfaceConfig.Theme.Colours[props.kind]
			else nil
		if colour then
			if props.active then
				return colour
			else
				return colour:Lerp(Color3.new(0, 0, 0), 0.25)
			end
		end
		return nil
	end, { props.style, props.image, props.kind, props.active })

	local buttonText = React.useMemo(function()
		return if props.active then props.text else props.disabledText
	end, { props.active, props.text, props.disabledText })

	return e("TextButton", {
		BackgroundTransparency = backgroundTransparency,
		BackgroundColor3 = backgroundColour,
		AnchorPoint = props.anchorPoint,
		Size = props.size,
		Position = props.position,
		Text = "",
		BorderSizePixel = 0,

		[React.Event.MouseButton1Click] = props.onActivate,
		[React.Event.MouseEnter] = props.onHoverIn,
		[React.Event.MouseLeave] = props.onHoverOut,
	}, {
		label = e("TextLabel", {
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
		corner = e("UICorner", {
			CornerRadius = UDim.new(0, 10),
		}),
	}, props.children)
end

return Button
