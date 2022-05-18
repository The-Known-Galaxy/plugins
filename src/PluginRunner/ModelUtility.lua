local DEFAULTS = {
	INITIAL_DOCK_STATE = Enum.InitialDockState.Float,
	INITIAL_ENABLED = false,
	DATA_WIDGET = {
		MIN_WIDTH = 100,
		MIN_HEIGHT = 50,
	},
}

local modelDataWidgetInfo = DockWidgetPluginGuiInfo.new(
	DEFAULTS.INITIAL_DOCK_STATE,
	DEFAULTS.INITIAL_ENABLED,
	false,
	DEFAULTS.DATA_WIDGET.MIN_WIDTH,
	DEFAULTS.DATA_WIDGET.MIN_HEIGHT,
	DEFAULTS.DATA_WIDGET.MIN_WIDTH,
	DEFAULTS.DATA_WIDGET.MIN_HEIGHT
)

local modelDataWidgetRootFrame = Instance.new("Frame")
modelDataWidgetRootFrame.Name = "RootFrame"
modelDataWidgetRootFrame.Size = UDim2.new(1, 0, 1, 0)

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 0)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.Name = "ListLayout"
listLayout.Parent = modelDataWidgetRootFrame
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Name = "[B]SizeLabel"
sizeLabel.Size = UDim2.new(1, 0, 0.5, 0)
sizeLabel.Parent = modelDataWidgetRootFrame
sizeLabel.BackgroundTransparency = 1
sizeLabel.Text = ""
sizeLabel.TextScaled = true
sizeLabel.TextStrokeTransparency = 1
sizeLabel.Visible = false
sizeLabel.RichText = true
sizeLabel.Font = Enum.Font.Code

local nameLabel = Instance.new("TextLabel")
nameLabel.Name = "[A]NameLabel"
nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
nameLabel.Parent = modelDataWidgetRootFrame
nameLabel.BackgroundTransparency = 1
nameLabel.Text = ""
nameLabel.TextScaled = true
nameLabel.TextStrokeTransparency = 1
nameLabel.Visible = true
nameLabel.RichText = true
nameLabel.Font = Enum.Font.Code

local modelChangedConnection: RBXScriptConnection
local function setSelectionText()
	local firstObject = game.Selection:Get()[1]
	if firstObject and firstObject:IsA("Model") then
		local _cframe: CFrame, size: Vector3 = firstObject:GetBoundingBox()
		local str = string.format("%.3f, %.3f, %.3f", size.X, size.Y, size.Z)
		sizeLabel.Visible = true
		sizeLabel.Text = "<b>Bounding Box Size:</b> " .. str
		nameLabel.Text = "<b>Name:</b> " .. firstObject.Name
		nameLabel.Size = UDim2.new(1, 0, 0.5, 0)

		if not (modelChangedConnection and modelChangedConnection.Connected) then
			modelChangedConnection = firstObject.Changed:Connect(function(_propertyName: string)
				setSelectionText()
			end)
		end
	else
		sizeLabel.Visible = false
		nameLabel.Text = "No Model selected"
		nameLabel.Size = UDim2.new(1, 0, 1, 0)

		if modelChangedConnection and modelChangedConnection.Connected == false then
			modelChangedConnection:Disconnect()
		end
	end
end

setSelectionText()
game.Selection.SelectionChanged:Connect(setSelectionText)

return {
	hasButton = true,
	hasWidget = true,
	rootGuiObject = modelDataWidgetRootFrame,
	buttonInfo = {
		buttonId = "button_1",
		tooltip = "Show extra Model data window.",
		iconname = "",
		text = "Model Data",
		ClickableWhenViewportHidden = true,
	},
	widgetInfo = {
		title = "Model Data",
		dockWidgetPluginGuiInfo = modelDataWidgetInfo,
	},
}
