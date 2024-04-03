local Selection = game:GetService("Selection")

local ConfigureHilt = require(script.Parent.ConfigureHilt)
local ImportHilt = require(script.Parent.ImportHilt)
local Button = require(script.Parent.Parent.Parent.Modules.Interface.Components.Button)
local Padding = require(script.Parent.Parent.Parent.Modules.Interface.Components.Padding)
local Panel = require(script.Parent.Parent.Parent.Modules.Interface.Components.Panel)
local Text = require(script.Parent.Parent.Parent.Modules.Interface.Components.Text)
local NextId = require(script.Parent.Parent.Parent.Modules.Utilities.NextId)
local TextFormat = require(script.Parent.Parent.Parent.Modules.Utilities.TextFormat)
local Promise = require(script.Parent.Parent.Parent.Parent.Libraries.Promise)
local React = require(script.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement

export type Props = {
	configurationMenu: PluginMenu,
}

local MAIN_PADDING = 10
local TEXT_PADDING = MAIN_PADDING
local BUTTON_SIZE_Y = 40

local function HiltSetProcessorApp(props: Props)
	local filteredSelection, setFilteredSelection = React.useState(Selection:Get())
	local unfilteredSelection, setUnfilteredSelection = React.useState({})
	local nextOrder = NextId.New()

	local selectionCount = React.useMemo(function()
		return #filteredSelection
	end)

	-- import logic
	local canImport = React.useMemo(function()
		return selectionCount > 0
	end, { selectionCount })

	-- hilt part configuration logic
	local configureMode, setConfigureMode = React.useState(false)
	local previousUnfilteredSelection, setPreviousUnfilteredSelection = React.useState({})

	local configureModeButtonActivated = React.useCallback(function()
		local newConfigureMode = not configureMode
		if newConfigureMode then
			setPreviousUnfilteredSelection(unfilteredSelection)
			Selection:Set({})
		else
			Selection:Set(previousUnfilteredSelection)
			setPreviousUnfilteredSelection({})
		end

		setConfigureMode(newConfigureMode)
	end, { configureMode, previousUnfilteredSelection, unfilteredSelection })

	-- opening context menu as a side effect when unfiltered selection changes and configure mode is
	React.useEffect(function()
		local promise
		if configureMode and #unfilteredSelection > 0 then
			promise = Promise.new(function(resolve)
				local chosenAction: PluginAction? = props.configurationMenu:ShowAsync()
				if chosenAction then
					ConfigureHilt.ConfigureSelectionByActionId(unfilteredSelection, chosenAction.ActionId)
					Selection:Set({})
				end
				resolve()
			end)

			return function()
				promise:cancel()
			end
		end
		return nil
	end, { configureMode, unfilteredSelection })

	-- keeping track of selections - both filtered for import and not
	React.useEffect(function()
		local connection = Selection.SelectionChanged:Connect(function()
			local newSelection = Selection:Get()
			setUnfilteredSelection(newSelection)
			setFilteredSelection(ImportHilt.FilterSelectionForImportableModels(newSelection))
		end)

		return function()
			connection:Disconnect()
		end
	end)

	return e("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	}, {
		Layout = e("UIListLayout", {
			Padding = UDim.new(0, MAIN_PADDING),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
		Padding = e(
			Padding,
			{
				all = UDim.new(0, MAIN_PADDING),
			} :: Padding.Props
		),
		UsagePanel = e(
			Panel,
			{
				autoSize = true,
				native = {
					AnchorPoint = Vector2.new(0.5, 0),
					Size = UDim2.new(1, 0, 0, 120),
					LayoutOrder = nextOrder(),
				},
			} :: Panel.Props,
			{
				Layout = e("UIListLayout", {
					Padding = UDim.new(0, 2),
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				Padding = e(
					Padding,
					{
						all = UDim.new(0, TEXT_PADDING),
					} :: Padding.Props
				),
				Title = e(
					Text,
					{
						style = "title",
						text = "Hilt Set Processor",
						autoSize = true,
						native = {
							Size = UDim2.new(1, 0, 0, 25),
							LayoutOrder = nextOrder(),
						},
					} :: Text.Props
				),
				Description = e(
					Text,
					{
						text = `Use this tool import and configure lightsaber hilts. Currently supports importing lightsaber hilts and previewing materials. Detailed guides on how to use this are in: {TextFormat.Hyperlink(
							"the-known-galaxy.github.io/plugins"
						)}`,
						autoSize = true,
						native = {
							Size = UDim2.new(1, 0, 1, -25),
							Position = UDim2.new(0, 0, 0, 25),
							TextYAlignment = Enum.TextYAlignment.Top,
							LayoutOrder = nextOrder(),
						},
					} :: Text.Props
				),
			}
		),
		ButtonPanel = e(
			Panel,
			{
				autoSize = true,
				native = {
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 0),
					Size = UDim2.new(1, 0, 0, 60),
					LayoutOrder = nextOrder(),
				},
			} :: Panel.Props,
			{
				Padding = e(Padding, {
					all = UDim.new(0, MAIN_PADDING),
				}),
				Layout = e("UIListLayout", {
					Padding = UDim.new(0, MAIN_PADDING),
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
				ImportButton = e(
					Button,
					{
						style = "Solid",
						kind = "Primary",
						text = `Import {selectionCount} Hilt{if selectionCount > 1 then "s" else ""}...`,
						disabledText = "Select Hilts to Import",
						active = canImport,
						onActivate = if canImport
							then function()
								ImportHilt.Import(filteredSelection)
							end
							else nil,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(1, 0, 0, BUTTON_SIZE_Y),
						},
					} :: Button.Props
				),
				ConfigureButton = e(
					Button,
					{
						style = "Solid",
						kind = "Secondary",
						text = `Turn {if configureMode then "off" else "on"} Hilt Configuration Mode`,
						active = true,
						onActivate = configureModeButtonActivated,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(1, 0, 0, BUTTON_SIZE_Y),
						},
					} :: Button.Props
				),
			}
		),
	})
end

return HiltSetProcessorApp
