--[=[
	@class Config
	
	Plugin configuration module.
]=]
local Config = {
	--[=[
		Change to true to enable hot reloading support.
		Opening a place containing the code synced via Rojo will cause the plugin to be reloaded in edit mode.
		(No need for play solo or the hotswap plugin.)
	]=]
	UseDevelopmentSource = true,
}

return Config
