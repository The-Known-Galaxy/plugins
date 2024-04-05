--[=[
	@class PluginWidgetFrame
	
	If a plugin wishes to develop a user interface inside a [DockWidgetPluginGui], then this frame should be the top-level element.
	Provides a small navbar at the top with universal information.
]=]
local Padding = require(script.Parent.Components.Padding)
local Text = require(script.Parent.Components.Text)
local InterfaceConfig = require(script.Parent.InterfaceConfig)
local Config = require(script.Parent.Parent.Parent.Config)
local Promise = require(script.Parent.Parent.Parent.Parent.Libraries.Promise)
local React = require(script.Parent.Parent.Parent.Parent.Libraries.React)
local Permissions = require(script.Parent.Parent.Permissions)

local e = React.createElement
export type Props = {
	children: any?,
}

local DOCK_SIZE = 32

local function PluginWidgetFrame(props: Props)
	local accessLevel, setAccessLevel = React.useState(Permissions.AccessLevels.NoAccess)

	React.useEffect(function()
		Promise.new(function(resolve)
			resolve(Permissions.GetAccessLevel())
		end):andThen(function(level: Permissions.AccessLevel)
			setAccessLevel(level)
		end, warn)
	end, {})

	return e("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		DockBar = e("Frame", {
			Size = UDim2.new(1, 0, 0, DOCK_SIZE),
			BackgroundTransparency = 0,
			BackgroundColor3 = InterfaceConfig.Theme.Colours.Primary,
			BorderSizePixel = 0,
		}, {
			Padding = e(Padding, { horizontal = UDim.new(0, 10), vertical = UDim.new(0, 5) } :: Padding.Props),
			NameDisplay = e(
				Text,
				{
					style = "code",
					text = `{Config.Name.Long}`,
					bold = true,
					native = {
						Size = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.new(0, 0, 0, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
					},
				} :: Text.Props
			),
			VersionDisplay = e(
				Text,
				{
					style = "code",
					text = `{Config.Version}`,
					native = {
						Size = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.new(0, 0, 0.5, 0),
						TextXAlignment = Enum.TextXAlignment.Left,
					},
				} :: Text.Props
			),
			TKTIcon = e("ImageLabel", {
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.new(0, 24, 0, 24),
				BackgroundTransparency = 1,
				Image = Config.MainIcon,
			}, {
				Corner = e("UICorner", {
					CornerRadius = UDim.new(1, 0),
				}),
			}),
			AccessLevelDisplay = e(Text, {
				style = "code",
				text = accessLevel.Name,
				bold = true,
				italics = true,
				native = {
					Size = UDim2.new(0.5, 0, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					TextXAlignment = Enum.TextXAlignment.Right,
				},
			}),
		}),
		RootFrameForOtherPluginGuis = e("Frame", {
			Size = UDim2.new(1, 0, 1, -DOCK_SIZE),
			Position = UDim2.new(0, 0, 0, DOCK_SIZE),
			BackgroundTransparency = 1,
			BorderSizePixel = 1,
			ClipsDescendants = true,
		}, props.children),
	})
end

return PluginWidgetFrame
