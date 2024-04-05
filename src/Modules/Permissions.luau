--[=[
    @class Permissions
    
    General purpose permissions module for handling permissions of various plugin features, including usage of the plugin itself.
]=]

local GroupService = game:GetService("GroupService")
local StudioService = game:GetService("StudioService")

local GroupIds = require(script.Parent.Data.GroupIds)
local RankData = require(script.Parent.Data.RankData)
local InterfaceConfig = require(script.Parent.Interface.InterfaceConfig)
local Logger = require(script.Parent.Logger)
local Llama = require(script.Parent.Parent.Parent.Libraries.Llama)

export type UserGroup = {
	EmblemId: number,
	EmblemUrl: string,
	Id: number,
	IsInClan: boolean,
	IsPrimary: boolean,
	Name: string,
	Rank: number,
	Role: string,
}
export type UserGroups = { UserGroup }
--[=[
	@interface AccessLevel
	@within Permissions
	.Name string
	.Level number
	.Theme ColourPalette
	.IsAtLevel (UserGroups) -> boolean
]=]
export type AccessLevel = {
	Name: string,
	Level: number,
	Theme: InterfaceConfig.ColourPalette,
	IsAtLevel: (UserGroups) -> boolean,
}

local Permissions = {}

--[=[
	@prop AccessLevels {[string]: AccessLevel}
	@within Permissions
	
	All the access levels of a the plugin knows about.
]=]
Permissions.AccessLevels = {
	Programmer = {
		Name = "Programmer",
		Level = math.huge,
		Theme = InterfaceConfig.ColourPalettes.Firecracker,
		IsAtLevel = function(groups: UserGroups): boolean
			for _, group: UserGroup in groups do
				if group.Id == GroupIds.TESTERS then
					if group.Rank >= RankData.TESTERS.Engineer then
						return true
					end
				elseif group.Id == GroupIds.TKG then
					if group.Rank >= RankData.TKG.Engineer then
						return true
					end
				end
			end
			return false
		end,
	} :: AccessLevel,
	Developer = {
		Name = "General Developer",
		Level = 20,
		Theme = InterfaceConfig.ColourPalettes.Painting,
		IsAtLevel = function(groups: UserGroups): boolean
			for _, group: UserGroup in groups do
				if group.Id == GroupIds.TESTERS then
					if group.Rank > RankData.TESTERS.Contractor then
						return true
					end
				elseif group.Id == GroupIds.TKG then
					if group.Rank >= RankData.TKG.Developer then
						return true
					end
				end
			end
			return false
		end,
	} :: AccessLevel,
	Contributor = {
		Name = "Contributor",
		Level = 10,
		Theme = InterfaceConfig.ColourPalettes.Cold,
		IsAtLevel = function(groups: UserGroups): boolean
			for _, group: UserGroup in groups do
				if group.Id == GroupIds.TESTERS then
					if group.Rank >= RankData.TESTERS.Contractor then
						return true
					end
				elseif group.Id == GroupIds.TKG then
					if group.Rank >= RankData.TKG.Contributor then
						return true
					end
				end
			end
			return false
		end,
	} :: AccessLevel,
	NoAccess = {
		Name = "No Access",
		Level = 0,
		Theme = InterfaceConfig.ColourPalettes.Cold,
		IsAtLevel = function(): boolean
			return true
		end,
	} :: AccessLevel,
}

function Permissions._getGroups(): UserGroups | false
	local loggedInUserId = StudioService:GetUserId()
	if loggedInUserId == 0 then
		Logger.Warn("Cannot detect who is logged into the Studio. UserID is 0.")
		return false
	end
	return GroupService:GetGroupsAsync(loggedInUserId)
end

--[=[
	@yields
	@since v0.1.0 
	Whether the currently logged in Studio user can user this plugin.
]=]
function Permissions.CanUsePlugin(): boolean
	local accessLevel = Permissions.GetAccessLevel()
	return not (accessLevel == Permissions.AccessLevels.NoAccess)
end

--[=[
	@yields
	@since v0.3.0 
	Gets the access level of the currently logged in Studio user.
]=]
function Permissions.GetAccessLevel(): AccessLevel
	local userGroups = Permissions._getGroups()
	if userGroups == false then
		return Permissions.AccessLevels.NoAccess
	end

	local userAccessLevels = Llama.Dictionary.filter(Permissions.AccessLevels, function(level: AccessLevel)
		return level.IsAtLevel(userGroups)
	end)

	local sortedAccessLevels = Llama.List.sort(
		Llama.Dictionary.values(userAccessLevels),
		function(level1: AccessLevel, level2: AccessLevel)
			return level1.Level > level2.Level
		end
	)

	if #sortedAccessLevels == 0 then
		return Permissions.AccessLevels.NoAccess
	else
		return sortedAccessLevels[1]
	end
end

function Permissions.CanUseHiltProcessor()
	local userGroups = Permissions._getGroups()
	if userGroups == false then
		return userGroups
	end

	for _, group: UserGroup in userGroups do
		if group.Id == GroupIds.TESTERS then
			if group.Rank >= RankData.TESTERS.Architect then
				return true
			end
		elseif group.Id == GroupIds.TKG then
			if group.Rank >= RankData.TKG.Developer then
				return true
			end
		end
	end

	return true
end

return Permissions
