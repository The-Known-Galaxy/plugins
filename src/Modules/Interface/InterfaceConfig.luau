--!strict
--[=[
	@class InterfaceConfig
	
	Configuration settings for the frontend of the plugin framework.
]=]
local InterfaceConfig = {}

export type ColourPalette = {
	Primary: Color3, -- should be a bright vibrant colour
	Secondary: Color3, -- a different colour to primary. Should be a good contrast
	Tertiary: Color3, -- used rarely. Can be anything
	Accent: Color3, -- should be very bright, almost white-ish
	Text: Color3, -- should be very dark
}

InterfaceConfig.ColourPalettes = {
	["Firecracker"] = {
		Primary = Color3.fromHex("#ff785a"),
		Secondary = Color3.fromHex("#fff05a"),
		Tertiary = Color3.fromHex("#ffaa5a"),
		Accent = Color3.fromHex("#ffd25a"),
		Text = Color3.fromHex("#191919"),
	} :: ColourPalette,
	["Painting"] = {
		Primary = Color3.fromHex("#30bced"),
		Secondary = Color3.fromHex("#fc5130"),
		Tertiary = Color3.fromHex("#303036"),
		Accent = Color3.fromHex("#fffaff"),
		Text = Color3.fromHex("#050401"),
	} :: ColourPalette,
	["Cold"] = {
		Primary = Color3.fromHex("#cae5ff"),
		Secondary = Color3.fromHex("#6f8ab7"),
		Tertiary = Color3.fromHex("#89bbfe"),
		Accent = Color3.fromHex("#acedff"),
		Text = Color3.fromHex("#151416"),
	} :: ColourPalette,
}

InterfaceConfig.Springs = {
	-- react-spring defaults
	Default = { tension = 170, friction = 26 } :: any,
	Gentle = { tension = 120, friction = 14 } :: any,
	Wobbly = { tension = 180, friction = 12 } :: any,
	Stiff = { tension = 210, friction = 20 } :: any,
	Slow = { tension = 280, friction = 60 } :: any,
	Molasses = { tension = 280, friction = 120 } :: any,

	-- custom
	Fast = { mass = 0.5, tension = 200, friction = 25 } :: any,
	Snappy = { mass = 0.1, tension = 400, friction = 10 } :: any,
}

InterfaceConfig.Theme = {
	Background = Color3.fromRGB(40, 40, 40),
	Font = Enum.Font.Ubuntu,
	CornerRadius = UDim.new(0, 10),
	Colours = InterfaceConfig.ColourPalettes.Painting,
}

return InterfaceConfig
