local HiltMaterials = require(script.Parent.Parent.Parent.Parent.Modules.Data.Materials.HiltMaterials)
local ButtonMask = require(script.Parent.Parent.Parent.Parent.Modules.Interface.Components.ButtonMask)
local Text = require(script.Parent.Parent.Parent.Parent.Modules.Interface.Components.Text)
local InterfaceConfig = require(script.Parent.Parent.Parent.Parent.Modules.Interface.InterfaceConfig)
local Colour = require(script.Parent.Parent.Parent.Parent.Modules.Utilities.Colour)
local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)
local ReactSpring = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.ReactSpring)

local e = React.createElement
export type Props = {
	materialData: HiltMaterials.Material,
	selected: boolean,
	onSelect: (materialName: string) -> (),
	children: any?,
}

local DEFAULT_PROPS: Props = {
	materialData = HiltMaterials.materials.alloy_metal :: HiltMaterials.Material,
	selected = false,
	onSelect = function() end,
}

local function MaterialFragment(props: Props)
	props = Llama.Dictionary.merge(DEFAULT_PROPS, props)

	local hovered, setHovered = React.useState(false)

	local styles = ReactSpring.useSpring({
		strokeThickness = if props.selected then 3 else 0,
		offset = if props.selected
			then Vector2.new(-0.4, 0)
			elseif hovered then Vector2.new(0, 0)
			else Vector2.new(0.4, 0),
		colourAlpha = if props.selected then 0.8 else 0.4,
		config = InterfaceConfig.Springs.Snappy,
	})

	local text = React.useMemo(function()
		if props.selected then
			return "Remove Preview"
		else
			if hovered then
				return `Preview {props.materialData.name}`
			else
				return props.materialData.name
			end
		end
	end, { hovered, props.selected, props.materialData.name })

	return e("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 0,
	}, {
		MaterialName = e(
			Text,
			{
				text = text,
				style = "normal",
				bold = hovered,
				colour = Colour.Inverse(props.materialData.color),
				native = {
					Size = UDim2.new(1, 0, 1, 0),
				},
			} :: Text.Props
		),
		ButtonFunctionality = e(
			ButtonMask,
			{
				onActivate = function()
					props.onSelect(props.materialData.name)
				end,
				onHoverIn = function()
					setHovered(true)
				end,
				onHoverOut = function()
					setHovered(false)
				end,
				native = {
					ZIndex = 10,
				},
			} :: ButtonMask.Props
		),
		Stroke = e("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = InterfaceConfig.Theme.Colours.Accent,
			LineJoinMode = Enum.LineJoinMode.Round,
			Thickness = styles.strokeThickness,
			Transparency = 0,
		}),
		Corner = e("UICorner", {
			CornerRadius = InterfaceConfig.Theme.CornerRadius,
		}),
		Gradient = e("UIGradient", {
			Color = styles.colourAlpha:map(function(value)
				return ColorSequence.new(
					props.materialData.color,
					props.materialData.color:Lerp(Color3.fromHSV(0, 0, 0.8), value)
				)
			end),
			Offset = styles.offset,
			Rotation = 70,
		}),
	}, props.children)
end

return MaterialFragment
