--[=[
	@class RankData

	This file contains all the ranks that we would ever need to use.

	A very useful script to get these ranks printed in this format is the following command you can enter to your command bar:
	```lua
	local id = 33268242;
	local data = game:GetService("GroupService"):GetGroupInfoAsync(id);
	local str = "";
	for _, roleData in ipairs(data.Roles) do
		str ..= ("\n\t[\"%s\"] = %s,"):format(roleData.Name, roleData.Rank)
	end
	print(str)
	```
]=]

--[=[
	@type GroupRanks {[string]: number} 
	@within RankData
]=]
export type GroupRanks = { [string]: number }

local RankData = {}

--[=[
	@prop TESTERS GroupRanks
	@within RankData 
	Beta tester group.
]=]
RankData.TESTERS = {
	["Beta Tester"] = 1,
	["Senior Tester"] = 2,
	["Lead Tester"] = 3,
	["Faction Leadership"] = 5,
	["Contractor"] = 190,
	["Musical Composer"] = 200,
	["3D Animator"] = 210,
	["Architect"] = 220,
	["Engineer"] = 230,
	["Lead Developer"] = 235,
	["Service Droid"] = 240,
	["Assistant Project Manager"] = 250,
	["Chief Development Officer"] = 250,
	["Project Manager"] = 255,
}

--[=[
	@prop TKG GroupRanks
	@within RankData 
	Main Genre group.
]=]
RankData.TKG = {
	["Explorer"] = 10,
	["Beta Testers"] = 15,
	["Legendary Explorer"] = 20,
	["Faction Leadership"] = 30,
	["Moderator"] = 40,
	["Administrator"] = 50,
	["Community Manager"] = 60,
	["Contributor"] = 61,
	["Developer"] = 70,
	["Engineer"] = 80,
	["Senior Developer"] = 85,
	["Service Droid"] = 90,
	["Assistant Project Manager"] = 100,
	["Project Manager"] = 255,
}

--[=[
	@prop KRE GroupRanks
	@within RankData 
	Robing group. Used to be called Kai's Robe Emporium, but is now called Outer Rim Outfitting & Supply
]=]
RankData.KRE = {
	["Galactic Citizens"] = 1,
	["Apparel Advisors"] = 252,
	["Chief Operations Officer"] = 253,
	["Assistant Project Manager"] = 254,
	["Project Manager"] = 255,
}

--[=[
	@prop JEDI GroupRanks
	@within RankData 
	Main Jedi group.
]=]
RankData.JEDI = {
	["Force Sensitive"] = 1,
	["Youngling I"] = 2,
	["Youngling II"] = 3,
	["Youngling III"] = 4,
	["Initiate"] = 5,
	["Service Initiate"] = 6,
	["Padawan Learner"] = 7,
	["Jedi Knight"] = 8,
	["Jedi Guardian"] = 9,
	["Jedi Consular"] = 10,
	["Jedi Sentinel"] = 11,
	["Jedi Instructor"] = 12,
	["Temple Guard"] = 13,
	["Jedi Master"] = 14,
	["Jedi Elder"] = 15,
	["Jedi High Council"] = 16,
	["Jedi Ghost"] = 17,
	["Developer"] = 50,
	["Service Droids"] = 52,
	["Quartermaster"] = 53,
	["Master of the Order"] = 54,
	["Grandmaster"] = 255,
}

--[=[
	@prop COREC GroupRanks
	@within RankData 
	Council of Reconciliation.
]=]
RankData.COREC = {
	["Jedi"] = 246,
	["Jedi Ambassador"] = 247,
	["Jedi Peacekeeper"] = 248,
	["Jedi Investigator"] = 249,
	["Rotating Member"] = 251,
	["Permanent Member"] = 252,
	["Senior Member"] = 253,
	["Master of the Order"] = 254,
	["Grandmaster"] = 255,
}

--[=[
	@prop COREA GroupRanks
	@within RankData 
	Council of Reassignment.
]=]
RankData.COREA = {
	["Jedi"] = 10,
	["Weapon Specialist"] = 20,
	["Jedi Shadow"] = 30,
	["Jedi Sage"] = 40,
	["Rotating Member"] = 251,
	["Permanent Member"] = 252,
	["Senior Member"] = 253,
	["Master of the Order"] = 254,
	["Grandmaster"] = 255,
}

--[=[
	@prop COFK GroupRanks
	@within RankData 
	Council of First Knowledge.
]=]
RankData.COFK = {
	["Jedi"] = 10,
	["Jedi Artisan"] = 20,
	["Jedi Mystic"] = 30,
	["Lore Keeper"] = 60,
	["Rotating Member"] = 70,
	["Permanent Member"] = 80,
	["Senior Member"] = 253,
	["Master of the Order"] = 254,
	["Grandmaster"] = 255,
}

--[=[
	@prop TSF GroupRanks
	@within RankData 
	Temple Security Force.
]=]
RankData.TSF = {
	["Trainee"] = 10,
	["Watchman"] = 20,
	["Scout"] = 21,
	["Ranger"] = 30,
	["Templar"] = 40,
	["Gate Captain"] = 50,
	["Gate Master"] = 251,
	["Council of Reconciliation"] = 252,
	["Chief of Security"] = 253,
	["Master of the Order"] = 254,
	["Grandmaster"] = 255,
}

--[=[
	@prop JSC GroupRanks
	@within RankData 
	Jedi Service Corps.
]=]
RankData.JSC = {
	["ACE Student"] = 1,
	["Evaluation"] = 20,
	["Graduated Student"] = 30,
	["Intern"] = 35,
	["Mentor"] = 50,
	["Instructor"] = 60,
	["Assistant Taskmaster"] = 70,
	["Taskmaster"] = 80,
	["Council of Reassignment"] = 85,
	["Jedi High Council"] = 90,
	["Master of the Order"] = 254,
	["Grandmaster"] = 255,
}

--[=[
	@prop JA GroupRanks
	@within RankData 
	Jedi Academy.
]=]
RankData.JA = {
	["Youngling I"] = 10,
	["Youngling II"] = 20,
	["Youngling III"] = 30,
	["Graduated Student"] = 40,
	["Teacher"] = 50,
	["Instructor"] = 60,
	["Assistant Headmaster"] = 70,
	["Headmaster"] = 80,
	["Council of First Knowledge"] = 90,
	["Jedi High Council"] = 100,
	["Master of the Order"] = 254,
	["Grandmaster"] = 255,
}

--[=[
	@prop TG GroupRanks
	@within RankData 
	Temple Guard.
]=]
RankData.TG = {
	["Candidate"] = 10,
	["Guardsman"] = 20,
	["Senior Guardsman"] = 30,
	["Veteran Guardsman"] = 40,
	["Honor Guard"] = 50,
	["Instructor"] = 60,
	["Sergeant-At-Arms"] = 70,
	["Warden"] = 80,
	["Captain"] = 90,
	["Commandant"] = 100,
	["Chief of Security"] = 110,
	["Master of the Order"] = 125,
	["Grandmaster"] = 255,
}

--[=[
	@prop JAT GroupRanks
	@within RankData 
	Jedi Assault Team.
]=]
RankData.JAT = {
	["Aspirant"] = 149,
	["Novice"] = 150,
	["Duelist"] = 200,
	["Neophyte"] = 210,
	["Warrior"] = 220,
	["Vindicator"] = 230,
	["Captain"] = 232,
	["Battlemaster"] = 235,
	["Barsen'thor"] = 236,
	["Master of the Order"] = 254,
	["Grandmaster"] = 255,
}

--[=[
	@prop LA GroupRanks
	@within RankData 
	Librarian's Assembly.
]=]
RankData.LA = {
	["Student"] = 246,
	["Scholar"] = 247,
	["Historian"] = 249,
	["Archivist"] = 250,
	["Librarian"] = 251,
	["Chief Librarian"] = 252,
	["Caretaker of First Knowledge"] = 253,
	["Master of the Order"] = 254,
	["Grandmaster"] = 255,
}

--[=[
	@prop SITH GroupRanks
	@within RankData 
	Main Sith group.
]=]
RankData.SITH = {
	["Hopeful"] = 1,
	["Acolyte"] = 2,
	["Adept"] = 8,
	["Apprentice"] = 9,
	["Sith Knight"] = 10,
	["Sith Warrior"] = 13,
	["Sith Inquisitor"] = 14,
	["Dark Honor Guard"] = 16,
	["Sith Overseer"] = 17,
	["Sith Lord"] = 25,
	["Darth"] = 26,
	["Sith Elder"] = 245,
	["Developer"] = 246,
	["Dark Council"] = 248,
	["Sith Wraith"] = 249,
	["Powerbase"] = 250,
	["Sith Quartermaster"] = 253,
	["Dark Lord of the Sith"] = 254,
	["The Force"] = 255,
}

--[=[
	@prop DHG GroupRanks
	@within RankData 
	Dark Honor Guards.
]=]
RankData.DHG = {
	["Initiate"] = 1,
	["Guardsman"] = 2,
	["Senior Guardsman"] = 3,
	["Lance Corporal"] = 4,
	["Corporal"] = 5,
	["Sergeant"] = 6,
	["Lieutenant"] = 7,
	["Captain"] = 8,
	["Commander"] = 9,
	["Powerbase"] = 10,
	["Dark Lord of the Sith"] = 254,
	["The Force"] = 255,
}

--[=[
	@prop SA GroupRanks
	@within RankData 
	Sith Academy.
]=]
RankData.SA = {
	["Acolyte I"] = 120,
	["Acolyte II"] = 130,
	["Acolyte III"] = 140,
	["Acolyte IV"] = 150,
	["Acolyte V"] = 160,
	["Graduated Acolyte"] = 170,
	["Aspiring Teacher"] = 180,
	["Teacher"] = 190,
	["Assistant Overseer"] = 200,
	["Overseer"] = 210,
	["Assistant Headmaster"] = 220,
	["Headmaster"] = 225,
	["Inner Circle"] = 230,
	["Overlord"] = 235,
	["Powerbase"] = 245,
	["Dark Lord of the Sith"] = 250,
	["The Force"] = 255,
}

--[=[
	@prop SOAK GroupRanks
	@within RankData 
	Sphere of Ancient Knowledge.
]=]
RankData.SOAK = {
	["Neophyte"] = 170,
	["Sith Scribe"] = 180,
	["Sith Loremaster"] = 190,
	["Sith Curator"] = 200,
	["Sith Antiquarian"] = 210,
	["Sith Conservator"] = 215,
	["Inner Circle"] = 220,
	["Overlord"] = 230,
	["Powerbase"] = 240,
	["Dark Lord of the Sith"] = 250,
	["The Force"] = 255,
}

--[=[
	@prop SOED GroupRanks
	@within RankData 
	Sphere of Expansion & Diplomacy.
]=]
RankData.SOED = {
	["Neophyte"] = 170,
	["Sith Raider"] = 180,
	["Sith Juggernaut"] = 190,
	["Sith Sorcerer"] = 200,
	["Sith Warlord"] = 210,
	["Sith Warlock"] = 215,
	["Inner Circle"] = 220,
	["Overlord"] = 230,
	["Powerbase"] = 240,
	["Dark Lord of the Sith"] = 250,
	["The Force"] = 255,
}

--[=[
	@prop SOLJ GroupRanks
	@within RankData 
	Sphere of Laws & Justice.
]=]
RankData.SOLJ = {
	["Neophyte"] = 170,
	["Sith Enforcer"] = 180,
	["Sith Warden"] = 190,
	["Sith Interrogator"] = 200,
	["Sith Marshal"] = 210,
	["Sith Executioner"] = 215,
	["Inner Circle"] = 220,
	["Overlord"] = 240,
	["Powerbase"] = 250,
	["Dark Lord of the Sith"] = 254,
	["The Force"] = 255,
}

--[=[
	@prop SOSP GroupRanks
	@within RankData 
	Sphere of Sith Philosophy.
]=]
RankData.SOSP = {
	["Neophyte"] = 170,
	["Sith Lurker"] = 180,
	["Sith Marauder"] = 190,
	["Sith Savant"] = 200,
	["Sith Reaper"] = 210,
	["Sith Augur"] = 215,
	["Inner Circle"] = 220,
	["Overlord"] = 252,
	["Powerbase"] = 253,
	["Dark Lord of the Sith"] = 254,
	["The Force"] = 255,
}

--[=[
	@prop SOM GroupRanks
	@within RankData 
	Sphere of Mysteries.
]=]
RankData.SOM = {
	["Neophyte"] = 170,
	["Sith Lurker"] = 180,
	["Sith Marauder"] = 190,
	["Sith Savant"] = 200,
	["Sith Reaper"] = 210,
	["Sith Augur"] = 215,
	["Inner Circle"] = 220,
	["Overlord"] = 252,
	["Powerbase"] = 253,
	["Dark Lord of the Sith"] = 254,
	["The Force"] = 255,
}

--[=[
	@prop SODS GroupRanks
	@within RankData 
	Sphere of Defense & Security.
]=]
RankData.SODS = {
	["Neophyte"] = 170,
	["Sith Sentry"] = 180,
	["Sith Centurion"] = 190,
	["Sith Shaman"] = 200,
	["Sith Archon"] = 210,
	["Sith Alchemist"] = 215,
	["Inner Circle"] = 220,
	["Overlord"] = 252,
	["Powerbase"] = 253,
	["Dark Lord of the Sith"] = 254,
	["The Force"] = 255,
}

--[=[
	@prop SOT GroupRanks
	@within RankData 
	Sphere of Technology.
]=]
RankData.SOT = {
	["Neophyte"] = 170,
	["Sith Excavator"] = 180,
	["Sith Fabricator"] = 190,
	["Sith Engineer"] = 200,
	["Sith Architect"] = 210,
	["Sith Mastermind"] = 215,
	["Inner Circle"] = 220,
	["Overlord"] = 252,
	["Powerbase"] = 253,
	["Dark Lord of the Sith"] = 254,
	["The Force"] = 255,
}

--[=[
	@prop PATHWAY {["JEDI" | "SITH"]: {[number]: true}}
	@within RankData 
	Pathways.
]=]
RankData.PATHWAY = {
	JEDI = {
		[RankData.JEDI["Jedi Guardian"]] = true,
		[RankData.JEDI["Jedi Consular"]] = true,
		[RankData.JEDI["Jedi Sentinel"]] = true,
	},
	SITH = {
		[RankData.SITH["Sith Warrior"]] = true,
		[RankData.SITH["Sith Inquisitor"]] = true,
	},
}

return RankData
