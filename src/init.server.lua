local PluginToolbar = plugin:CreateToolbar("TKG Suite")

local Janitor = require(script.Packages.Janitor)
local WidgetUtility = require(script.WidgetUtility)

local PluginEnabledStatus = {
	ModelUtility = true,
	AutoFolder = false,
}

type WidgetInfo = {
	title: string,
	dockWidgetPluginGuiInfo: DockWidgetPluginGuiInfo,
}

type ButtonInfo = {
	buttonId: string,
	tooltip: string,
	iconname: string,
	text: string,
	ClickableWhenViewportHidden: boolean,
}
type PluginData = {
	hasButton: boolean,
	hasWidget: boolean,
	rootGuiObject: GuiObject,
	buttonInfo: ButtonInfo,
	widgetInfo: WidgetInfo,
}

local function createWidget(pluginData: PluginData): DockWidgetPluginGui
	return plugin:CreateDockWidgetPluginGui(pluginData.widgetInfo.title, pluginData.widgetInfo.dockWidgetPluginGuiInfo)
end

local function setupPlugin(pluginData: PluginData)
	if pluginData.hasButton == true then
		local buttonInfo: ButtonInfo = pluginData.buttonInfo
		local newDockButton = PluginToolbar:CreateButton(
			buttonInfo.buttonId or "NO_BUTTON_ID",
			buttonInfo.tooltip or "NO_TOOLTIP",
			buttonInfo.iconname or "NO_ICON_NAME",
			buttonInfo.text or "NO_TEXT"
		)
		newDockButton.ClickableWhenViewportHidden = buttonInfo.ClickableWhenViewportHidden or false

		if pluginData.hasWidget == true then
			local widget = createWidget(pluginData)
			WidgetUtility.syncDockButtonToWidget(newDockButton, widget)
			WidgetUtility.syncWidgetColor(widget)
			pluginData.rootGuiObject.Parent = widget
		end
	end
end

--// MODEL UTILITY
if PluginEnabledStatus.ModelUtility == true then
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

	setupPlugin({
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
	})
end

--//AutoFolder
if PluginEnabledStatus.AutoFolder == true then
	local PLUGIN_NAME = "AutoFolder"
	local janitor = Janitor.new()

	local State = {
		CurrentParent = workspace,
		CurrentSelectedFolder = nil,
	}

	local PluginMenu = plugin:CreatePluginMenu(math.random(), PLUGIN_NAME, "")
	local ParentAction = plugin:CreatePluginAction(
		"ParentAction",
		"Set foldering parent...",
		"Sets the target parent every new object should have.",
		"",
		true
	)

	ParentAction.Triggered:Connect(function()
		print("action triggered")
		State.CurrentParent = State.CurrentSelectedFolder or workspace
	end)
	PluginMenu:AddAction(ParentAction)

	game.Selection.SelectionChanged:Connect(function()
		print("selection changed")
		local firstObject = game.Selection:Get()[1]
		if firstObject and firstObject:IsA("Folder") then
			print("assigned first object")
			State.CurrentSelectedFolder = firstObject
		else
			print("unassigned first object")
			State.CurrentSelectedFolder = nil
		end
	end)

	local function setupFolder(folderInstance: Folder)
		folderInstance:SetAttribute("Parentable", true)
		janitor:Add(
			folderInstance:GetAttributeChangedSignal("Parentable"):Connect(function()
				folderInstance:SetAttribute("Parentable", true)
				PluginMenu:ShowAsync()
			end),
			nil,
			folderInstance:GetDebugId() .. ""
		)
	end

	for _, descendant in pairs(game:GetDescendants()) do
		if descendant:IsA("Folder") then
			setupFolder(descendant)
		end
	end

	game.DescendantAdded:Connect(function(descendant)
		if descendant:IsA("Folder") then
			setupFolder(descendant)
		end
	end)
	game.DescendantRemoving:Connect(function(descendant)
		if descendant:IsA("Folder") then
			janitor:Remove(descendant:GetDebugId() .. "")
		end
	end)

	workspace.ChildAdded:Connect(function(child)
		if child:IsA("BasePart") or child:IsA("Model") then
			print("child reparented")
			child.Parent = State.CurrentParent
		end
	end)
end
