--!strict

export type KeyWordList = { string }
export type SectionName = "pommel" | "grip" | "switch" | "emitter"

return {
	basePartMaterial = Enum.Material.Metal,

	basePartColour = Color3.fromRGB(163, 162, 165),
	primaryPartColour = Color3.fromRGB(132, 132, 130),

	attributes = {
		primaryHiltPart = "PrimaryHiltPart",
		fixedHiltPart = "FixedHiltPart",
		crystalHiltPart = "CrystalHiltPart",
	},

	rootPartName = "root",
	doubleGripSuffix = "_double_grip",
	staffSuffix = "_staff",

	sections = {
		[1] = "pommel",
		[2] = "grip",
		[3] = "switch",
		[4] = "emitter",
	} :: { SectionName },

	keywords = {
		sectionKeywords = {
			[1] = { "pommel", "endcap", "cap" },
			[2] = { "grip", "body", "handle", "handel", "handol" },
			[3] = { "switch", "switche" },
			[4] = { "emitter", "emiiter", "emmiter", "emiter", "emmitur", "ommiter", "emiitter" },
		},

		root = { "root", "roott", "core" },
		details = {
			"detail",
			"details",
			"detailing",
			"detale",
			".0",
		},
		doubleGrip = {
			"handle_long",
			"long",
			"griplong",
			"grip_long",
			"long_grip",
			"handlelong",
			"handle.long",
			"long.handle",
			"longhandle",
			"longgrip",
			"long_grip",
			"long_handle",
			"double_handle",
			"double.grip",
		},
		staffGrip = {
			"staff", -- ideal
			"staf",
			"staaf",
			"pike",
			"pyke",
		},
		primary = { "prim", "primary", "prime" },
		secondary = { "sec", "second", "secondary" },
		tertiary = { "tret", "tert", "tertiary" },
		fixed = { "fixed", "fixt", "fixet", "fxed", "fxd" },
		crystal = { "crystal", "krystal", "kyber" },
	},
}
