local Selection = game:GetService("Selection")

local ImportHilt = require(script.Parent.ImportHilt)
local Button = require(script.Parent.Parent.Parent.Modules.Interface.Components.Button)
local Panel = require(script.Parent.Parent.Parent.Modules.Interface.Components.Panel)
local Text = require(script.Parent.Parent.Parent.Modules.Interface.Components.Text)
local NextId = require(script.Parent.Parent.Parent.Modules.Utilities.NextId)
local TextFormat = require(script.Parent.Parent.Parent.Modules.Utilities.TextFormat)
local Llama = require(script.Parent.Parent.Parent.Parent.Libraries.Llama)
local React = require(script.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement

local MAIN_PADDING = 10
local TEXT_PADDING = 5

local function HiltSetProcessorApp(_props)
	local selection, setSelection = React.useState(Selection:Get())
	local nextOrder = NextId.New()

	React.useEffect(function()
		local connection = Selection.SelectionChanged:Connect(function()
			setSelection(Llama.List.filter(Selection:Get(), function(value: Instance)
				return value:IsA("Model")
			end))
		end)

		return function()
			connection:Disconnect()
		end
	end)

	local selectionCount = React.useMemo(function()
		return #selection
	end)

	local canImport = React.useMemo(function()
		return selectionCount > 0
	end, { selectionCount })

	return e("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	}, {
		UsagePanel = e(Panel, {
			anchorPoint = Vector2.new(0.5, 0),
			size = UDim2.new(1, 0, 0, 120),
			layoutOrder = nextOrder(),
		}, {
			Title = e(
				Text,
				{
					style = "title",
					text = "Hilt Set Processor",
					native = {
						Size = UDim2.new(1, 0, 0, 25),
					},
				} :: Text.Props
			),
			Description = e(
				Text,
				{
					text = `Use this tool import and configure lightsaber hilts. Currently supports importing lightsaber hilts and previewing materials. Detailed guides on how to use this are in: {TextFormat.Hyperlink(
						"the-known-galaxy.github.io/plugins/docs"
					)}`,
					native = {
						Size = UDim2.new(1, 0, 1, -25),
						Position = UDim2.new(0, 0, 0, 25),
						TextYAlignment = Enum.TextYAlignment.Top,
					},
				} :: Text.Props
			),
			Padding = e("UIPadding", {
				PaddingBottom = UDim.new(0, TEXT_PADDING),
				PaddingTop = UDim.new(0, TEXT_PADDING),
				PaddingLeft = UDim.new(0, TEXT_PADDING),
				PaddingRight = UDim.new(0, TEXT_PADDING),
			}),
		}),
		ButtonPanel = e(
			Panel,
			{
				anchorPoint = Vector2.new(0.5, 0),
				position = UDim2.new(0.5, 0, 0, 10),
				size = UDim2.new(1, 0, 0, 60),
				layoutOrder = nextOrder(),
			} :: Panel.Props,
			{
				ImportButton = e(
					Button,
					{
						style = "Solid",
						kind = "Primary",
						text = `Import {selectionCount} Hilt{if selectionCount > 1 then "s" else ""}`,
						disabledText = "Select Hilts to Import",
						active = canImport,
						onActivate = if canImport
							then function()
								ImportHilt.Import()
							end
							else nil,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Position = UDim2.new(0.5, 0, 0, 10),
							Size = UDim2.new(1, 0, 0, 40),
						},
					} :: Button.Props
				),
				-- FlexItem = e("UIFlexItem", {
				-- 	FlexMode = "Shrink", -- Custom, Fill, Grow, None, Shrink
				-- 	GrowRatio = 1, -- only used in FlexMode: Custom
				-- 	ShrinkRatio = 1, -- only used in FlexMode: Custom
				-- 	ItemLineAlignment = "Automatic",
				-- }),
			}
		),
		Layout = e("UIListLayout", {
			Padding = UDim.new(0, MAIN_PADDING),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,

			-- beta flex properties
			-- Wraps = false,
			-- HorizontalFlex = "Fill", -- no enums for these exist yet: None, Fill, SpaceAround, SpaceBetween, SpaceEvenly
			-- VerticalFlex = "None",
			-- ItemLineAlignment = "Automatic", -- enums: Automatic, Center, End, Start, Stretch
		}),
		Padding = e("UIPadding", {
			PaddingBottom = UDim.new(0, MAIN_PADDING),
			PaddingTop = UDim.new(0, MAIN_PADDING),
			PaddingLeft = UDim.new(0, MAIN_PADDING),
			PaddingRight = UDim.new(0, MAIN_PADDING),
		}),
	})
end

return HiltSetProcessorApp
