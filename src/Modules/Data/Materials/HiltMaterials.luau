export type Material = {
	name: string,
	color: Color3,
	material: Enum.Material,
	price: number?,
	collectible: boolean?,
}

export type Materials = { [string]: Material }

local Materials = {
	alloy_metal = {
		name = "Alloy Metal",
		color = Color3.fromRGB(109, 109, 99),
		material = Enum.Material.Metal,
	},
	arcetron = {
		name = "Arcetron",
		color = Color3.fromRGB(63, 127, 122),
		material = Enum.Material.Metal,
	},
	aurodium = {
		name = "Aurodium",
		color = Color3.fromRGB(165, 112, 22),
		material = Enum.Material.Metal,
		price = 5000,
	},
	bronzium = {
		name = "Bronzium",
		color = Color3.fromRGB(119, 110, 81),
		material = Enum.Material.Metal,
	},
	cerakote = {
		name = "Cerakote",
		color = Color3.fromRGB(59, 57, 62),
		material = Enum.Material.Metal,
	},
	chromium = {
		name = "Chromium",
		color = Color3.fromRGB(173, 176, 186),
		material = Enum.Material.Metal,
	},
	copper = {
		name = "Copper",
		color = Color3.fromRGB(216, 144, 112),
		material = Enum.Material.Metal,
	},
	corundum = {
		name = "Corundum",
		color = Color3.fromRGB(185, 142, 185),
		material = Enum.Material.Metal,
		price = 5000,
	},
	crodium = {
		name = "Crodium",
		color = Color3.fromRGB(48, 15, 11),
		material = Enum.Material.Metal,
		price = 3500,
	},
	dolovite = {
		name = "Dolovite",
		color = Color3.fromRGB(174, 12, 28),
		material = Enum.Material.Metal,
		collectible = true, -- christmas 2023 crucible 20/20 collectibles
	},
	doonium = {
		name = "Doonium",
		color = Color3.fromRGB(59, 68, 46),
		material = Enum.Material.Metal,
		price = 5000,
	},
	duralium = {
		name = "Duralium",
		color = Color3.fromRGB(16, 37, 47),
		material = Enum.Material.Metal,
		price = 3500,
	},
	duraplast = {
		name = "Duraplast",
		color = Color3.fromRGB(226, 226, 224),
		material = Enum.Material.SmoothPlastic,
	},
	durasteel = {
		name = "Durasteel",
		color = Color3.fromRGB(132, 132, 130),
		material = Enum.Material.Metal,
	},
	durite = {
		name = "Durite",
		color = Color3.fromRGB(19, 15, 12),
		material = Enum.Material.Metal,
		price = 3500,
	},
	electrum_plated = {
		name = "Electrum-Plated",
		color = Color3.fromRGB(242, 215, 69),
		material = Enum.Material.Metal,
		price = 5000,
	},
	haysian_smelt = {
		name = "Haysian Smelt",
		color = Color3.fromRGB(148, 115, 39),
		material = Enum.Material.Metal,
	},
	lamina_steel = {
		name = "Lamina Steel",
		color = Color3.fromRGB(138, 148, 27),
		material = Enum.Material.Metal,
	},
	matte = {
		name = "Matte",
		color = Color3.fromRGB(35, 37, 40),
		material = Enum.Material.SmoothPlastic,
	},
	mygeeto_campaign = {
		name = "Mygetoo Campaign",
		color = Color3.fromRGB(137, 106, 53),
		material = Enum.Material.Metal,
		price = 5000,
	},
	neuranium = {
		name = "Neuranium",
		color = Color3.fromRGB(60, 50, 47),
		material = Enum.Material.Metal,
		price = 3500,
	},
	orichalc = {
		name = "Orichalc",
		color = Color3.fromRGB(198, 167, 119),
		material = Enum.Material.Metal,
	},
	osmiridium = {
		name = "Osmiridium",
		color = Color3.fromRGB(183, 113, 19),
		material = Enum.Material.Metal,
		price = 5000,
	},
	polished_bronzium = {
		name = "Polished Bronzium",
		color = Color3.fromRGB(97, 79, 40),
		material = Enum.Material.Metal,
	},
	slivian_iron = {
		name = "Slivian Iron",
		color = Color3.fromRGB(235, 189, 172),
		material = Enum.Material.Metal,
	},
	umbara_campaign = {
		name = "Umbara Campaign",
		color = Color3.fromRGB(122, 148, 174),
		material = Enum.Material.Metal,
		collectible = true, -- christmas 2023 ossus 20/20 collectibles
	},
}
return Materials
