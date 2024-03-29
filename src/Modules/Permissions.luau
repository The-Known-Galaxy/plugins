--[=[
    @class Permissions
    
    General purpose permissions module for handling permissions of various plugin features, including usage of the plugin itself.
]=]

local GroupService = game:GetService("GroupService")
local ServerStorage = game:GetService("ServerStorage")

local StudioService = game:GetService("StudioService")

local Config = require(ServerStorage.TKGSuite.Plugin.Config)
local RankData = require(ServerStorage.TKGSuite.Plugin.Modules.Data.RankData)
local Logger = require(ServerStorage.TKGSuite.Plugin.Modules.Logger)

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

local Permissions = {}

--[=[
    Whether the currently logged in Studio user can user this plugin.
    @yields
]=]
function Permissions.CanUsePlugin(): boolean
	local loggedInUserId = StudioService:GetUserId()
	if loggedInUserId == 0 then
		Logger.Warn("Cannot detect who is logged into the Studio. UserID is 0.")
		return false
	end
	local userGroups: UserGroups = GroupService:GetGroupsAsync(loggedInUserId)

	for _, group in userGroups do
		if group.Id == Config.GroupIds.SienarTechSystemsDevelopment then
			if group.Rank >= RankData.TESTERS.Contractor then
				return true
			end
		end
	end
	return false
end

return Permissions
