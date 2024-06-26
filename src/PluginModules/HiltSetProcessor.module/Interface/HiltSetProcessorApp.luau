local Selection = game:GetService("Selection")

local MaterialManager = require(script.Parent.Parent.MaterialManager)
local ConfigureHilt = require(script.Parent.Parent.ConfigureHilt)
local ImportHilt = require(script.Parent.Parent.ImportHilt)
local MaterialFragment = require(script.Parent.MaterialFragment)
local HiltValidator = require(script.Parent.Parent.HiltValidator)
local HiltMaterials = require(script.Parent.Parent.Parent.Parent.Modules.Data.Materials.HiltMaterials)
local Button = require(script.Parent.Parent.Parent.Parent.Modules.Interface.Components.Button)
local Padding = require(script.Parent.Parent.Parent.Parent.Modules.Interface.Components.Padding)
local Panel = require(script.Parent.Parent.Parent.Parent.Modules.Interface.Components.Panel)
local ScrollingList = require(script.Parent.Parent.Parent.Parent.Modules.Interface.Components.ScrollingList)
local Text = require(script.Parent.Parent.Parent.Parent.Modules.Interface.Components.Text)
local NextId = require(script.Parent.Parent.Parent.Parent.Modules.Utilities.NextId)
local TextFormat = require(script.Parent.Parent.Parent.Parent.Modules.Utilities.TextFormat)
local Llama = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Llama)
local Promise = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.Promise)
local React = require(script.Parent.Parent.Parent.Parent.Parent.Libraries.React)
local VisualiseHilt = require(script.Parent.Parent.VisualiseHilt)

local e = React.createElement

export type Props = {
	configurationMenu: PluginMenu,
}

local MAIN_PADDING = 10
local TEXT_PADDING = MAIN_PADDING
local BUTTON_SIZE_Y = 40

local function HiltSetProcessorApp(props: Props)
	local unfilteredSelection, setUnfilteredSelection = React.useState({})
	local unimportedSelection, setUnimportedSelection = React.useState({})
	local importedModelSelection, setImportedModelSelection = React.useState({})
	local modelSelection, setModelSelection = React.useState({})
	local lastVisualisation, setLastVisualisation = React.useState(os.time())

	local nextOrder = NextId.New()

	local _unfilteredSelectionCount = React.useMemo(function()
		return #unfilteredSelection
	end, { unfilteredSelection })

	local unimportedSelectionCount = React.useMemo(function()
		return #unimportedSelection
	end, { unimportedSelection })

	local importedModelSelectionCount = React.useMemo(function()
		return #importedModelSelection
	end, { importedModelSelection })

	local modelSelectionCount = React.useMemo(function()
		return #modelSelection
	end, { modelSelection })

	-- import logic
	local canImport = React.useMemo(function()
		return unimportedSelectionCount > 0
	end, { unimportedSelectionCount })

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
		if
			configureMode
			and #unfilteredSelection > 0
			and #ConfigureHilt.FilterSelectionForConfigurableHiltParts(unfilteredSelection) > 0
		then
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
		local function updateSelection()
			local newSelection = Selection:Get()
			setUnfilteredSelection(newSelection)
			setUnimportedSelection(ImportHilt.FilterSelectionForImportableModels(newSelection))
			setImportedModelSelection(ImportHilt.FilterSelectionForImportedModels(newSelection))
			setModelSelection(Llama.List.filter(newSelection, function(value: Instance): boolean
				return value:IsA("Model")
			end))
		end

		updateSelection()
		local connection = Selection.SelectionChanged:Connect(updateSelection)

		return function()
			connection:Disconnect()
		end
	end, {})

	-- material stuff
	local showMaterialPreviewList = React.useMemo(function()
		return importedModelSelectionCount > 0
	end, { importedModelSelectionCount })

	local applyHiltMaterial = React.useCallback(function(realMaterialName: string)
		MaterialManager.ToggleMaterialPreviewForSelection(
			importedModelSelection,
			HiltMaterials.NameToInternalName[realMaterialName]
		)

		-- VERY BAD IDEA
		-- triggers a re-render of the component since "state has changed" (when in reality only the table pointer has changed, and not the actual contents themselves)
		-- doing this because i want the button selected values to update on the material list, after applying a material
		-- but there isn't another way of doing it that i've come up with
		-- so this is it...
		setImportedModelSelection(Llama.List.copy(importedModelSelection))
	end, { importedModelSelection })

	local materialList = React.useMemo(function()
		local list = {}
		for materialName, materialData in HiltMaterials.materials do
			local modelsWithMaterialPreviewApplied = 0
			for _, instance in importedModelSelection do
				if MaterialManager.ModelHasMaterialPreviewSpecific(instance, materialName) then
					modelsWithMaterialPreviewApplied += 1
				end
			end

			list[materialName] = e(
				MaterialFragment,
				{
					selected = modelsWithMaterialPreviewApplied > 0,
					materialData = materialData,
					onSelect = applyHiltMaterial,
				} :: MaterialFragment.Props
			)
		end
		return list
	end, { importedModelSelection, applyHiltMaterial })

	-- validation logic
	local canValidate = React.useMemo(function()
		return modelSelectionCount > 0
	end, { modelSelectionCount })

	local validationActivated = React.useCallback(function()
		local selectionResults = HiltValidator.RunValidationsOnSelection(unfilteredSelection)
		HiltValidator.OutputSelectionValidation(selectionResults)
	end, { unfilteredSelection })

	-- visualisation logic
	local canVisualise = React.useMemo(function()
		-- since the material preview list is dependent on proper lightsaber hilts being selected
		return showMaterialPreviewList
	end, { showMaterialPreviewList })

	local visualisationActivated = React.useCallback(function()
		VisualiseHilt.VisualiseRootsInSelection(importedModelSelection)
		setLastVisualisation(os.time())
	end, { importedModelSelection })

	local visualisationsExist = React.useMemo(function()
		return VisualiseHilt.VisualisationsExist()
	end, { lastVisualisation })

	local clearVisualsActivated = React.useCallback(function()
		VisualiseHilt.ClearAllVisualisations()
		setLastVisualisation(os.time())
	end, { lastVisualisation })

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
						text = `Use this tool import and configure lightsaber hilts. Currently supports importing lightsaber hilts, configuring hilt parts and previewing materials. Detailed guides on how to use this are in: {TextFormat.Hyperlink(
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
						text = `Import {unimportedSelectionCount} Hilt{if unimportedSelectionCount > 1 then "s" else ""}...`,
						disabledText = "Select Hilts to Import",
						active = canImport,
						onActivate = if canImport
							then function()
								ImportHilt.Import(unimportedSelection)
							end
							else nil,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(1, 0, 0, BUTTON_SIZE_Y),
							LayoutOrder = nextOrder(),
						},
					} :: Button.Props
				),
				ConfigureButton = e(
					Button,
					{
						style = "Solid",
						kind = if configureMode then "Secondary" else "Primary",
						text = `Turn {if configureMode then "off" else "on"} Hilt Configuration Mode`,
						active = true,
						onActivate = configureModeButtonActivated,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(1, 0, 0, BUTTON_SIZE_Y),
							LayoutOrder = nextOrder(),
						},
					} :: Button.Props
				),
				ValidationButton = e(
					Button,
					{
						style = "Solid",
						kind = "Primary",
						text = `Validate {modelSelectionCount} Model{if modelSelectionCount > 1 then "s" else ""}`,
						active = canValidate,
						disabledText = "Select Imported Hilts to Validate...",
						onActivate = validationActivated,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(1, 0, 0, BUTTON_SIZE_Y),
							LayoutOrder = nextOrder(),
						},
					} :: Button.Props
				),
				VisualisationButton = e(
					Button,
					{
						style = "Solid",
						kind = "Primary",
						text = `Visualise Roots of {importedModelSelectionCount} Hilt{if importedModelSelectionCount
								> 1
							then "s"
							else ""}`,
						active = canVisualise,
						disabledText = "Select Imported Hilts to Visualise Roots...",
						onActivate = visualisationActivated,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(1, 0, 0, BUTTON_SIZE_Y),
							LayoutOrder = nextOrder(),
						},
					} :: Button.Props
				),
				ClearVisualsButton = visualisationsExist and e(
					Button,
					{
						style = "Solid",
						kind = "Primary",
						text = "Clear All Visualisations",
						active = visualisationsExist,
						onActivate = clearVisualsActivated,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(1, 0, 0, BUTTON_SIZE_Y),
							LayoutOrder = nextOrder(),
						},
					} :: Button.Props
				),
				Panel = e(
					Panel,
					{
						autoSize = true,
						-- autoSizeDirection = Enum.FillDirection.Vertical,
						native = {
							AnchorPoint = Vector2.new(0.5, 0),
							Size = UDim2.new(1, 0, 0, 200),
							LayoutOrder = nextOrder(),
						},
					} :: Panel.Props,
					{
						Padding = e(Padding, {
							vertical = UDim.new(0, MAIN_PADDING),
						}),
						Layout = e("UIListLayout", {
							Padding = UDim.new(0, MAIN_PADDING),
							FillDirection = Enum.FillDirection.Vertical,
							HorizontalAlignment = Enum.HorizontalAlignment.Center,
							VerticalAlignment = Enum.VerticalAlignment.Top,
							SortOrder = Enum.SortOrder.LayoutOrder,
						}),
						MaterialPreviewNote = e(
							Text,
							{
								style = "normal",
								text = "Select imported hilts, and then select a material from the list below to preview it. Select the material again to remove the preview.",
								autoSize = true,
								native = {
									Size = UDim2.new(1, -20, 0, 30),
									LayoutOrder = nextOrder(),
								},
							} :: Text.Props
						),
						MaterialList = showMaterialPreviewList and e(
							ScrollingList,
							{
								elements = materialList,
								listSortOrder = Enum.SortOrder.Name,
								listPadding = UDim.new(0, 8),
								startPadding = UDim.new(0, 5),
								endPadding = UDim.new(0, 5),
								leftPadding = UDim.new(0, 10),
								rightPadding = UDim.new(0, 10),
								native = {
									Size = UDim2.new(1, 0, 0, 200),
									LayoutOrder = nextOrder(),
								},
							} :: ScrollingList.Props
						),
					}
				),
			}
		),
	})
end

return HiltSetProcessorApp
