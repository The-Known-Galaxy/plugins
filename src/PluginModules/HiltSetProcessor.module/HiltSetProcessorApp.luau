local React = require(script.Parent.Parent.Parent.Parent.Libraries.React)

local e = React.createElement

local function HiltSetProcessorApp(_props)
	return e("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0.8, 0, 0.8, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
	})
end

return e(HiltSetProcessorApp)
