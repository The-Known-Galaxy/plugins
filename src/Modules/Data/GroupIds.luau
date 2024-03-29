--[=[
    @class GroupIds

    This file contains all the group IDs that we would ever need to use.
]=]

export type GroupId = number

local GroupIds = {}

--//Testers
GroupIds.TESTERS = 12675845

--// Genre Group
GroupIds.TKG = 6153729

--// Kai's Robe Emporium (TKG)
GroupIds.KRE = 14712470

--// Jedi.
GroupIds.JEDI = 5723250

--Councils.
GroupIds.COREC = 9500347
GroupIds.COREA = 9500349
GroupIds.COFK = 9500340

--Organisations.
GroupIds.TSF = 11243589
GroupIds.JSC = 11243601
GroupIds.JA = 11243615

--Divisions.
GroupIds.TG = 6153760
GroupIds.JAT = 6153791
GroupIds.LA = 9500429

--// Sith.
GroupIds.SITH = 9135125
GroupIds.DHG = 11851418
GroupIds.SA = 14810122 -- Sith Academy

--Spheres.
GroupIds.SOAK = 12723443
GroupIds.SOED = 12723437
GroupIds.SOLJ = 11780555
GroupIds.SOSP = 12723464
GroupIds.SOM = 13675803
GroupIds.SODS = 13675797
GroupIds.SOT = 33268242

return GroupIds
