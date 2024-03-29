--[=[
    @class Util
    
    Simple collection of utilities.
]=]
local process = require("@lune/process")

local Path = require("Path")

local Util = {}

--[=[
    Returns the plugin's path on the locally installed Studio plugin directory, or nil if it cannot find it.
]=]
function Util.GetLocalPluginPath(): string?
	local appDataDirectory = process.env.APPDATA
	if appDataDirectory ~= nil and appDataDirectory ~= "" then
		return Path.Join(appDataDirectory:gsub("Roaming", "Local"), "Roblox", "Plugins", "TKGSuite.rbxmx")
	else
		return nil
	end
end

return Util
