--[=[
    @class PluginFacade
    
    A dynamic plugin hot-reloader, used in developing the plugin.
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
export type PluginToolbarButtonName = string

--[=[
	@type SavedState any
	@within PluginFacade
]=]
export type SavedState = any

--[=[
	@interface PluginFacade
	@within PluginFacade
	.DevelopmentMode boolean -- Whether Hot-Reloading is turned on.
	.PluginObject Plugin -- Reference to the running plugin instance, from which native ROBLOX calls can be made.
]=]
export type PluginFacade = {
	DevelopmentMode: boolean,
	PluginObject: Plugin,
	_toolbars: { [PluginToolbarName]: PluginToolbar },
	_pluginGuis: any,
	_buttons: { [PluginToolbar]: { [PluginToolbarButtonName]: PluginToolbarButton } },
	_watching: any,
	_beforeUnload: any?,
	_currentRoot: Instance | any,
	_source: Instance | any,

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
	_toolbars = {},
	_pluginGuis = {},
	_buttons = {},
	_watching = {},
	_beforeUnload = nil,
	_currentRoot = nil,
	_source = nil,
}

--[=[
	Sets up the PluginFacade module.
]=]
function PluginFacade.Setup(self: PluginFacade, settings: PluginFacadeSetupSettings)
	self.DevelopmentMode = settings.DevelopmentMode
	self._currentRoot = settings.currentRoot
	self._source = settings.source
	self.PluginObject = settings.pluginReference
end

--[=[
	Abstraction for [Plugin:CreateToolbar]
]=]
function PluginFacade.CreateToolbar(self: PluginFacade, name: string): PluginToolbar
	if self._toolbars[name] then
		return self._toolbars[name]
	end

	local toolbar = self.PluginObject:CreateToolbar(name)

	self._toolbars[name] = toolbar

	return toolbar
end

--[=[
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

	local button = toolbar:CreateButton(name, tooltip, icon, text)

	existingButtons[name] = button

	return button
end

--[=[
	Wrapper around [Plugin:CreateDockWidgetPluginGui]
]=]
function PluginFacade.CreateDockWidgetPluginGui(
	self: PluginFacade,
	name: string,
	info: DockWidgetPluginGuiInfo
): DockWidgetPluginGui
	if self._pluginGuis[name] then
		return self._pluginGuis[name]
	end

	local gui = self.PluginObject:CreateDockWidgetPluginGui(name, info)
	self._pluginGuis[name] = gui

	return gui
end

--[=[
	Wrapper around [Plugin:GetMouse]
]=]
function PluginFacade.GetMouse(self: PluginFacade): PluginMouse
	return self.PluginObject:GetMouse()
end

--[=[
	Sets the method to call the next time the plugin tries to hot-reload.
]=]
function PluginFacade.RegisterPreUnloadHook(self: PluginFacade, callback: (...any) -> ...any)
	self._beforeUnload = callback
end

--[=[
	Loads the entire plugin.

	:::warning
	Will fail to run if `root.Plugin.Main` is not a [ModuleScript] that returns a `function`.
	:::
]=]
function PluginFacade.LoadPlugin(self: PluginFacade, savedState: SavedState)
	local ok, result = pcall(require, self._currentRoot.Plugin.Main)

	if not ok then
		warn("Plugin failed to load: " .. result)
		return
	end

	local requiredMainModule = result

	ok, result = pcall(requiredMainModule, self, savedState)

	if not ok then
		warn("Plugin failed to run: " .. result)
		return
	end
end

--[=[
	Unloads the entire plugin.
]=]
function PluginFacade.UnloadPlugin(self: PluginFacade): SavedState?
	if self._beforeUnload then
		local saveState = self._beforeUnload()
		self._beforeUnload = nil

		return saveState
	end
	return nil
end

--[=[
	Reloads the entire plugin. Used in hot-reloading.
]=]
function PluginFacade.HotReloadPlugin(self: PluginFacade)
	local saveState = self:UnloadPlugin()
	PluginFacade._currentRoot = self._source:Clone()

	self:LoadPlugin(saveState)
end

--[=[	
	Watch for changes to the given instance and its children, and then hot-reload the entire plugin to reflect those changes.

	:::note
	Recursive. Should be called on the root instance _once_, and it'll watch all descendant instances.
	:::
]=]
function PluginFacade.WatchInstanceForChanges(self: PluginFacade, instance: Instance): ()
	if self._watching[instance] then
		return
	end

	-- Don't watch ourselves!
	if instance == script then
		return
	end

	local connection1 = instance.Changed:Connect(function()
		print("Reloading due to", instance:GetFullName())

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
