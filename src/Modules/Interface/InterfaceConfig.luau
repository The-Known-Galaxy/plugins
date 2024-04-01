--!strict
local InterfaceConfig = {}

export type ColourPalette = {
	Primary: Color3,
	Secondary: Color3,
	Tertiary: Color3,
	Accent: Color3,
	Text: Color3,
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
		Tertiary = Color3.fromHex("#fffaff"),
		Accent = Color3.fromHex("#303036"),
		Text = Color3.fromHex("#050401"),
	} :: ColourPalette,
	["Cold"] = {
		Primary = Color3.fromHex("#cae5ff"),
		Secondary = Color3.fromHex("#6f8ab7"),
		Tertiary = Color3.fromHex("#89bbfe"),
		Accent = Color3.fromHex("#acedff"),
		Text = Color3.fromHex("#615d6c"),
	} :: ColourPalette,
}

InterfaceConfig.Springs = {
	-- react-spring defaults
	Default = { mass = 1, tension = 170, friction = 26 },
	Gentle = { mass = 1, tension = 120, friction = 14 },
	Wobbly = { mass = 1, tension = 180, friction = 12 },
	Stiff = { mass = 1, tension = 210, friction = 20 },
	Slow = { mass = 1, tension = 280, friction = 60 },
	Molasses = { mass = 1, tension = 280, friction = 120 },

	-- custom
	Fast = { mass = 0.5, tension = 200, friction = 25 },
}

InterfaceConfig.Theme = {
	Background = Color3.fromRGB(40, 40, 40),
	Font = Enum.Font.Ubuntu,
	Colours = InterfaceConfig.ColourPalettes.Firecracker,
}

return InterfaceConfig
