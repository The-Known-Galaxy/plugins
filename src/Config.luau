--[=[
	@class Config
	
	Plugin configuration module.
]=]

local Config = {}

--[=[
	@prop UseDevelopmentSource boolean
	@within Config
	
	Change to `true` to enable hot reloading support.
	You must rebuild the plugin and the place for this to take effect.
	Opening a place containing the code synced via Rojo will cause the plugin to be reloaded in edit mode.
	(No need for play solo or the hotswap plugin.)
]=]
Config.UseDevelopmentSource = false

--[=[
	@prop Version string
	@within Config
	
	Plugin version.
]=]
Config.Version = "0.2.0"

Config.Name = {}
--[=[
	@prop Name.Long string 
	@within Config

	Long name of the plugin. Meant for displaying nicely like a title.
]=]
Config.Name.Long = "TKG - The Known Tools"

--[=[
	@prop Name.Short string
	@within Config 

	Short name of the plugin. Meant for abbrevations or shorthand referencing.
]=]
Config.Name.Short = "TKT"

--[=[
	@prop Name.PluginRoot "TKGSuite"
	@within Config

	Name of the top-level instance all the Plugin files are stored in.
	:::warning
	SHOULD NOT BE CHANGED BETWEEN VERSIONS!
	:::
]=]
Config.Name.PluginRoot = "TKGSuite"

--[=[
	@prop MainIcon string
	@within Config

	Primary icon asset string for the plugin.
]=]
Config.MainIcon = nil -- non-ROBLOX Lune scripts also need to access this file, so initially nil

if script ~= nil then
	-- unless in a roblox context
	local images = require(script.Parent.Parent.Assets.images)
	Config.MainIcon = images.sienartech_notext
end

return Config
