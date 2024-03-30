--[=[
	@class PluginFacade

	Main Plugin manager and executor.
	Controls main plugin execution, and Hot-Reloading the plugin during development.
	Also acts as an interface and wrapper between the regular ROBLOX [Plugin] object and some of its methods.

	Original credit to the _concept and design_ of this module goes to Tiffany352 and Kampfkarren from (Original code copied from [Kampfkarren's Hoarcekat plugin Loader](https://github.com/Kampfkarren/hoarcekat/blob/master/src/Loader.server.lua))
	Although, I ([ShadowEngineer](https://github.com/ShadowEngineer)) spent a lot of hours refactoring and rewriting the module into 2 files (this one and [Loader]) alongside implementing some more custom behaviour, and properly documenting it.

	:::warning
	Caveats:
	1. Although it is fine to relatively or absolutely `require` this, it is **NOT** fine to directly use it form the `require` source.
		- This is because in development mode when hot reloading is turned on, the development source will be different from the original plugin invocation source, and that will cause erroneous behaviour.
		- It is best to **pass around a reference to the original [PluginFacade] instance**.
		- [PluginSubModule]s have this behaviour built in so you don't need to explicitly do it there.
		- If you need to write any new architectural code, keep this in mind.
	2. By virtue of what it is, you cannot work on this module itself (or [Loader]) for that matter with hot-reloading.
		- You must follow the traditional approach of rojo-syncing in the new code, and then right-click > Save Local Plugin on the top-level `TKGSuite` instance.
	:::

	Intended setup usage:
	```lua
	local shouldUseDevelopmentSource = true
	local developmentSource = ServerStorage:FindFirstChild(Config.Name.PluginRoot)

	-- assumes top-level plugin [Folder] is 2 parents up.
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
			warn(`{Config.Name.PluginRoot} development source is not present, running using built-in source.`)
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
	```
]=]

--[=[
	@interface PluginFacadeSetupSettings
	@within PluginFacade
	.DevelopmentMode boolean -- Whether to turn on development mode.
	.currentRoot Instance -- The root [Instance] where the plugin is stored in.
	.source Instance -- The root [Instance] from which the module "clones" itself for hot-reloading.
	.pluginReference Plugin -- A reference to the [Plugin] object available in the plugin calling script.
]=]
export type PluginFacadeSetupSettings = {
	DevelopmentMode: boolean,
	currentRoot: Instance,
	source: Instance,
	pluginReference: Plugin,
}
export type PluginToolbarName = string

--[=[
	@type SavedState any
	@within PluginFacade
]=]
export type SavedState = any

--[=[
	@prop DevelopmentMode boolean
	@within PluginFacade
	@readonly
	@since 0.1.0
	
	Whether the plugin's execution is currently in "developer mode".
	Can be used as a flag for having debug-specific features turned on.
	Also a proxy for whether Hot-Reloading is turned on.
]=]
--[=[
	@prop PluginObject Plugin
	@within PluginFacade
	@readonly
	@since 0.1.0
	
	Reference to the running plugin instance, from which native ROBLOX calls can be made.
	Since the [Plugin] instance is only accessible from the top-level execution [Script] that ROBLOX Studio executes the plugin with,
	a reference to it is stored in here for when native [Plugin] interfaces are required in other files.
]=]
--[=[
	@prop CurrentRoot Instance
	@within PluginFacade
	@readonly
	@since 0.1.0
	
	A reference to the top-level root of the plugin, wherever it might be. ALL REQUIRES SHOULD BE DIRECTED FROM HERE
]=]
--[=[
	@interface PluginFacade
	@within PluginFacade
	.DevelopmentMode boolean
	.PluginObject Plugin
	.CurrentRoot Instance
]=]
export type PluginFacade = {
	DevelopmentMode: boolean,
	PluginObject: Plugin,
	Root: Instance | any,
	_toolbars: { [PluginToolbarName]: PluginToolbar },
	_pluginGuis: any,
	_buttons: { [PluginToolbar]: { [string]: PluginToolbarButton } },
	_watching: any,
	_beforeUnload: any?,
	_source: Instance | any,
	_setup: boolean,

	Setup: (self: PluginFacade, settings: PluginFacadeSetupSettings) -> (),
	CreateToolbar: (self: PluginFacade, name: string) -> PluginToolbar,
	CreateButton: (
		self: PluginFacade,
		toolbar: PluginToolbar,
		name: string,
		tooltip: string,
		icon: string,
		text: string?
	) -> PluginToolbarButton,
	CreateDockWidgetPluginGui: (self: PluginFacade, name: string, info: DockWidgetPluginGuiInfo) -> DockWidgetPluginGui,
	RegisterPreUnloadHook: (self: PluginFacade, callback: (...any) -> ...any) -> (),
	LoadPlugin: (self: PluginFacade, savedState: SavedState) -> (),
	UnloadPlugin: (self: PluginFacade) -> SavedState?,
	HotReloadPlugin: (self: PluginFacade) -> (),
	WatchInstanceForChanges: (self: PluginFacade, instance: Instance) -> (),
}
local PluginFacade = {
	DevelopmentMode = false, -- default. Value influenced by the one in Config
	PluginObject = nil,
	Root = nil,
	_toolbars = {},
	_pluginGuis = {},
	_buttons = {},
	_watching = {},
	_beforeUnload = nil,
	_source = nil,
	_setup = false,
}

-- setup protection
local function assertNoSetup(module: PluginFacade)
	assert(
		module._setup,
		`Cannot call PluginFacade:{debug.info(2, "n")}() because the module is not setup. Call PluginFacade:Setup() first, or if you think you already HAVE :Setup the module, then ensure that you are getting this module by reference from Main.`
	)
end

--[=[
	@tag methods
	@tag constructor
	@since 0.1.0
	Sets up the PluginFacade module.
	Although not a traditional "constructor" that most Object Classes have in OOP, it sets up the rest of the module.

	:::warning
	Call this before any other methods! Otherwise, undefined or erroneous behaviour might occur.
	:::
]=]
function PluginFacade.Setup(self: PluginFacade, settings: PluginFacadeSetupSettings)
	self.DevelopmentMode = settings.DevelopmentMode
	self.Root = settings.currentRoot
	self.PluginObject = settings.pluginReference
	self._source = settings.source

	-- in-case this module is called from a different context and is not setup, none of the functions in the module should work.
	self._setup = true
end

--[=[
	@tag methods
	@since 0.1.0
	Abstraction for [Plugin:CreateToolbar]
]=]
function PluginFacade.CreateToolbar(self: PluginFacade, name: string): PluginToolbar
	assertNoSetup(self)
	if self._toolbars[name] then
		return self._toolbars[name]
	end

	local toolbar = self.PluginObject:CreateToolbar(name)
	self._toolbars[name] = toolbar

	return toolbar
end

--[=[
	@tag methods
	@since 0.1.0
	Abstraction for [PluginToolbar:CreateButton]
]=]
function PluginFacade.CreateButton(
	self: PluginFacade,
	toolbar: PluginToolbar,
	name: string,
	tooltip: string,
	icon: string,
	text: string?
): PluginToolbarButton
	assertNoSetup(self)
	local existingButtons = self._buttons[toolbar]

	if existingButtons then
		local existingButton = existingButtons[name]

		if existingButton then
			return existingButton
		end
	else
		existingButtons = {}
		self._buttons[toolbar] = existingButtons
	end

	local button = toolbar:CreateButton(name or "default name", tooltip or "default tooltip", icon or "", text)
	existingButtons[name] = button

	return button
end

--[=[
	@tag methods
	@since 0.1.0
	Wrapper around [Plugin:CreateDockWidgetPluginGui]
]=]
function PluginFacade.CreateDockWidgetPluginGui(
	self: PluginFacade,
	name: string,
	info: DockWidgetPluginGuiInfo
): DockWidgetPluginGui
	assertNoSetup(self)
	if self._pluginGuis[name] then
		return self._pluginGuis[name]
	end

	local gui = self.PluginObject:CreateDockWidgetPluginGui(name, info)
	self._pluginGuis[name] = gui

	return gui
end

--[=[
	@tag methods
	@since 0.1.0
	Wrapper around [Plugin:GetMouse].
]=]
function PluginFacade.GetMouse(self: PluginFacade): PluginMouse
	assertNoSetup(self)
	return self.PluginObject:GetMouse()
end

--[=[
	@tag methods
	@since 0.1.0
	Sets the method to call the next time the plugin tries to hot-reload.
]=]
function PluginFacade.RegisterPreUnloadHook(self: PluginFacade, callback: (...any) -> ...any)
	assertNoSetup(self)
	self._beforeUnload = callback
end

--[=[
	@tag methods
	@since 0.1.0
	Loads the entire plugin.

	:::warning
	Will fail to run if `root.Plugin.Main` is not a [ModuleScript] that returns a `function`.
	:::
]=]
function PluginFacade.LoadPlugin(self: PluginFacade, savedState: SavedState)
	assertNoSetup(self)
	-- this technically needs a pcall, but it's whatever
	local Logger = require(script.Parent.Modules.Logger)

	local ok, result = pcall(require, self.Root.Plugin.Main)

	if not ok then
		Logger.Warn("Plugin failed to load: " .. result)
		return
	end

	local requiredMainModule = result

	-- requiredMainModule(self, savedState) -- use this when testing things that break and you want to see the stack trace
	ok, result = pcall(requiredMainModule, self, savedState)

	if not ok then
		Logger.Warn("Plugin failed to run: " .. result)
		return
	end
end

--[=[
	@tag methods
	@since 0.1.0
	Unloads the entire plugin.
]=]
function PluginFacade.UnloadPlugin(self: PluginFacade): SavedState?
	assertNoSetup(self)

	local savedState = nil
	if self._beforeUnload then
		savedState = self._beforeUnload()
		self._beforeUnload = nil
	end

	-- cleanup of buttons and toolbars
	-- not necessary
	-- for _name: string, toolbar: PluginToolbar in self._toolbars do
	-- 	for _buttonName: string, button: PluginToolbarButton in self._buttons[toolbar] do
	-- 		button:Destroy()
	-- 	end
	-- 	self._buttons[toolbar] = nil
	-- 	toolbar:Destroy()
	-- end
	-- self._toolbars = {} :: any

	return savedState
end

--[=[
	@tag methods
	@since 0.1.0
	Reloads the entire plugin. Used in hot-reloading.
]=]
function PluginFacade.HotReloadPlugin(self: PluginFacade)
	assertNoSetup(self)
	local saveState = self:UnloadPlugin()
	PluginFacade.Root = self._source:Clone()

	self:LoadPlugin(saveState)
end

--[=[
	@tag methods
	@since 0.1.0
	Watch for changes to the given instance and its children, and then hot-reload the entire plugin to reflect those changes.

	:::note
	Recursive. Should be called on the root instance _once_, and it'll watch all descendant instances.
	:::
]=]
function PluginFacade.WatchInstanceForChanges(self: PluginFacade, instance: Instance): ()
	assertNoSetup(self)
	if self._watching[instance] then
		return
	end

	-- Don't watch ourselves!
	if instance == script then
		return
	end

	local connection1 = instance.Changed:Connect(function()
		print("Reloading from change in...", instance:GetFullName())

		self:HotReloadPlugin()
	end)

	local connection2 = instance.ChildAdded:Connect(function(child)
		self:WatchInstanceForChanges(child)
	end)

	local connections = { connection1, connection2 }

	self._watching[instance] = connections

	for _, child in ipairs(instance:GetChildren()) do
		self:WatchInstanceForChanges(child)
	end
end

return PluginFacade :: PluginFacade
