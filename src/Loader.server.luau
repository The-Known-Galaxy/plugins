-- Taken from https://github.com/tiffany352/Roblox-Tag-Editor/blob/bd48fb7ceea6bcd1cd9c515891ae4eb4eb9d1a71/src/Loader.server.lua#L24
-- Thank you Tiffany352!!!

-- ShadowEngineer: Taken from https://github.com/Kampfkarren/hoarcekat/blob/master/src/Loader.server.lua
-- Thank you to Tiffany352 and Kampfkarren!

-- Sanity check.
if not plugin then
	error("TKGSuite must be executed as a plugin!")
end

local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

-- RenderStepped errors out in Start Server, so we consider it a hostile environment even though it has a 3D view that we could potentially be using.
if not RunService:IsClient() then
	return
end

local Config = require(script.Parent.Config)
local PluginFacade = require(script.Parent.PluginFacade)

local shouldUseDevelopmentSource = Config.UseDevelopmentSource
local developmentSource = ServerStorage:FindFirstChild("TKGSuite")

-- The source that's shipped integrated into the plugin.
-- If this code is executing inside a locally installed plugin instance, then `builtInSource` will refer to that instance.
-- If not, it'll refer to the one directly parented to ServerStorage.
local builtInSource = script.Parent.Parent

-- `source` is where we should watch for changes.
-- `currentRoot` is the clone we make of source to avoid require()
-- returning stale values.
local mainPluginExecutionSource = builtInSource
local currentRoot = mainPluginExecutionSource

if shouldUseDevelopmentSource then
	if developmentSource ~= nil then
		mainPluginExecutionSource = developmentSource
		currentRoot = mainPluginExecutionSource
	else
		warn("TKGSuite development source is not present, running using built-in source.")
	end
end

PluginFacade:Setup({
	DevelopmentMode = shouldUseDevelopmentSource and developmentSource ~= nil,
	currentRoot = currentRoot,
	source = mainPluginExecutionSource,
	pluginReference = plugin,
})
PluginFacade:LoadPlugin()
PluginFacade:WatchInstanceForChanges(mainPluginExecutionSource)