-- local WidgetUtility = {}

-- function WidgetUtility.syncWidgetColor(widgetReference: DockWidgetPluginGui)
-- 	local function colorDescendant(descendant: Instance)
-- 		if descendant:IsA("GuiObject") then
-- 			descendant.BackgroundColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainBackground)

-- 			if descendant:IsA("GuiButton") or descendant:IsA("GuiLabel") or descendant:IsA("TextBox") then
-- 				descendant.TextColor3 = settings().Studio.Theme:GetColor(Enum.StudioStyleGuideColor.MainText)
-- 			end
-- 		end
-- 	end

-- 	local function colorWidget()
-- 		for _, descendant in pairs(widgetReference:GetDescendants()) do
-- 			colorDescendant(descendant)
-- 		end
-- 	end

-- 	colorWidget()
-- 	settings().Studio.ThemeChanged:Connect(colorWidget)

-- 	widgetReference.DescendantAdded:Connect(function(newDescendant)
-- 		colorDescendant(newDescendant)
-- 	end)
-- end

-- function WidgetUtility.syncDockButtonToWidget(dockButton: PluginToolbarButton, widget: DockWidgetPluginGui)
-- 	dockButton.Click:Connect(function()
-- 		widget.Enabled = not widget.Enabled
-- 	end)
-- end

-- return WidgetUtility
