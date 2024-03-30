--[=[
	@class Loader
	
	Primary plugin execution entry point.
	Runs the rest of the plugin.

	Originally taken from [Tag Editor Loader](https://github.com/tiffany352/Roblox-Tag-Editor/blob/bd48fb7ceea6bcd1cd9c515891ae4eb4eb9d1a71/src/Loader.server.lua#L24) by Kampfkarren.
	> Kampfkarren: Thank you Tiffany352!!!

	Then taken from [Hoarcekat Loader](https://github.com/Kampfkarren/hoarcekat/blob/master/src/Loader.server.lua).
	> ShadowEngineer: Thank you Kampfkarren!
]=]

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

local shouldUseDevelopmentSource = Config.DevelopmentMode
local developmentSource = ServerStorage:FindFirstChild(Config.Name.PluginRoot)

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
		warn(`{Config.Name.PluginRoot} running in development mode using development source in ServerStorage.`)
		mainPluginExecutionSource = developmentSource
		currentRoot = mainPluginExecutionSource
	else
		warn(`{Config.Name.PluginRoot} development source is not present, running using built-in source.`)
	end
end

local developmentMode = shouldUseDevelopmentSource and developmentSource ~= nil
PluginFacade:Setup({
	DevelopmentMode = developmentMode,
	currentRoot = currentRoot,
	source = mainPluginExecutionSource,
	pluginReference = plugin,
})
PluginFacade:LoadPlugin()
if developmentMode then
	PluginFacade:WatchInstanceForChanges(mainPluginExecutionSource)
end
