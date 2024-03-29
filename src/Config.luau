--[=[
	@class Config
	
	Plugin configuration module.
]=]

local Config = {}

--[=[
	@prop UseDevelopmentSource boolean
	@within Config
	
	Change to `true` to enable hot reloading support.
	Opening a place containing the code synced via Rojo will cause the plugin to be reloaded in edit mode.
	(No need for play solo or the hotswap plugin.)
]=]
Config.UseDevelopmentSource = false

return Config
