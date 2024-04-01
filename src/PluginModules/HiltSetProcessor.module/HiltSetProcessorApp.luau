local Selection = game:GetService("Selection")

local Button = require(script.Parent.Parent.Parent.Modules.Interface.Components.Button)
local React = require(script.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement

local function HiltSetProcessorApp(_props)
	local selection, setSelection = React.useState(Selection:Get())

	React.useEffect(function()
		local connection = Selection.SelectionChanged:Connect(function()
			setSelection(Selection:Get())
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
		ImportButton = e(
			Button,
			{
				style = "Solid",
				kind = "Primary",
				anchorPoint = Vector2.new(0.5, 0),
				position = UDim2.new(0.5, 0, 0, 50),
				size = UDim2.new(0, 300, 0, 40),
				text = `Import {selectionCount} Hilt{if selectionCount > 1 then "s" else ""}`,
				disabledText = "Select Hilts to Import",
				active = canImport,
				onActivate = canImport and function()
					print("clicked")
				end,
			} :: Button.Props
		),
	})
end

return HiltSetProcessorApp
