local PluginToolbar = plugin:CreateToolbar("TKG Suite")

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

local function syncWidgetColor(widgetReference: DockWidgetPluginGui)
	local function colorDescendant(descendant: Instance)
		if descendant:IsA("GuiObject") then
			descendant.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)

			if descendant:IsA("GuiButton") or descendant:IsA("GuiLabel") or descendant:IsA("TextBox") then
				descendant.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
			end
		end
	end

	local function colorWidget()
		for _, descendant in pairs(widgetReference:GetDescendants()) do
			colorDescendant(descendant)
		end
	end

	colorWidget()
	settings().Studio.ThemeChanged:Connect(colorWidget)

	widgetReference.DescendantAdded:Connect(function(newDescendant)
		colorDescendant(newDescendant)
	end)
end

local function syncDockButton(dockButton: PluginToolbarButton, widget: DockWidgetPluginGui)
	dockButton.Click:Connect(function()
		widget.Enabled = not widget.Enabled
	end)
end

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
			syncDockButton(newDockButton, widget)
			syncWidgetColor(widget)
			pluginData.rootGuiObject.Parent = widget
		end
	end
end

-- init
for _, child in pairs(script:GetChildren()) do
	if child:IsA("ModuleScript") then
		local pluginData: PluginData = require(child)
		setupPlugin(pluginData)
	end
end
