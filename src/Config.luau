--[=[
	@class Config
	
	Plugin configuration module.
	Houses configuration information about the entire plugin, and is meant to be the single source of truth for backend settings.
	Frontend settings are in [InterfaceConfig].
]=]

local Config = {}

--[=[
	@prop DevelopmentMode boolean
	@within Config
	
	Change to `true` to enable hot reloading support.
	You must rebuild the plugin and the place for this to take effect.
	Opening a place containing the code synced via Rojo will cause the plugin to be reloaded in edit mode.
	(No need for play solo or the hotswap plugin.)
]=]
Config.DevelopmentMode = false

--[=[
	@prop Version string
	@within Config
	
	Plugin version.
]=]
Config.Version = "v0.5.0"

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

--[=[
	@since v0.3.0 
	@prop ActionAndMenuId { [string]: string }
	@within Config
	A dictionary of IDs that are supposed to be shared plugin-wide, corresponding to the IDs for [PluginAction] objects and [PluginMenu] objects.
	Since these are supposed to be constant, they should never be changed.
	They are also hence managed from here - the entire plugin needs access to these.
]=]
Config.ActionAndMenuId = {
	ACTION_IMPORT_HILTS_IN_SELECTION = "ImportHiltsFromSelection",
	ACTION_SET_AS_PRIMARY_PART = "SetAsPrimaryPart",
	ACTION_SET_AS_FIXED_PART = "SetAsFixedPart",
	ACTION_SET_AS_CRYSTAL_PART = "SetAsCrystalPart",
	ACTION_VISUALISE_NAMED_AREAS = "VisualiseNamedAreas",

	MENU_CONFIGURE_HILT_PART = "ConfigureHiltParts",

	VALIDATE_ARCHIVES = "ValidateArchives",
}

return Config
