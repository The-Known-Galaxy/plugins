--[=[
    @class PluginFacade
    
    A dynamic plugin hot-reloader, used in developing the plugin.
]=]

export type PluginFacadeSetupSettings = {
	DevelopmentMode: boolean,
	currentRoot: Instance,
	source: Instance,
	pluginReference: Plugin,
}
export type PluginToolbarName = string
export type PluginToolbarButtonName = string
export type SavedState = any
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

	--[=[
        Sets up the PluginFacade instance.
    ]=]
	Setup: (self: PluginFacade, settings: PluginFacadeSetupSettings) -> (),

	--[=[
        Abstraction for plugin:CreateToolbar
    ]=]
	CreateToolbar: (self: PluginFacade, name: string) -> PluginToolbar,

	--[=[
        Abstraction for toolbar:CreateButton
    ]=]
	CreateButton: (
		self: PluginFacade,
		toolbar: PluginToolbar,
		name: string,
		tooltip: string,
		icon: string,
		text: string?
	) -> PluginToolbarButton,

	--[=[
        Wrapper around plugin:CreatePluginGui
    ]=]
	CreateDockWidgetPluginGui: (self: PluginFacade, name: string, info: DockWidgetPluginGuiInfo) -> DockWidgetPluginGui,

	--[=[
        Wrapper around plugin:GetMouse
    ]=]
	GetMouse: (self: PluginFacade) -> PluginMouse,

	--[=[
        Sets the method to call the next time the system tries to reload
    ]=]
	RegisterPreUnloadHook: (self: PluginFacade, callback: (...any) -> ...any) -> (),

	--[=[
        Loads the entire plugin.
    ]=]
	LoadPlugin: (self: PluginFacade, savedState: SavedState) -> (),

	--[=[
        Unloads the plugin.
    ]=]
	UnloadPlugin: (self: PluginFacade) -> SavedState?,

	--[=[
        Reloads the plugin. Used in hot-reloading.
    ]=]
	HotReloadPlugin: (self: PluginFacade) -> (),

	--[=[
        Watch for changes to the given instance and its children, and then hot-reload the entire plugin to reflect those changes.
    ]=]
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

function PluginFacade.Setup(self: PluginFacade, settings: PluginFacadeSetupSettings)
	self.DevelopmentMode = settings.DevelopmentMode
	self._currentRoot = settings.currentRoot
	self._source = settings.source
	self.PluginObject = settings.pluginReference
end

function PluginFacade.CreateToolbar(self: PluginFacade, name)
	if self._toolbars[name] then
		return self._toolbars[name]
	end

	local toolbar = self.PluginObject:CreateToolbar(name)

	self._toolbars[name] = toolbar

	return toolbar
end

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

function PluginFacade.GetMouse(self: PluginFacade): PluginMouse
	return self.PluginObject:GetMouse()
end

function PluginFacade.RegisterPreUnloadHook(self: PluginFacade, callback)
	self._beforeUnload = callback
end

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

function PluginFacade.UnloadPlugin(self: PluginFacade): SavedState?
	if self._beforeUnload then
		local saveState = self._beforeUnload()
		self._beforeUnload = nil

		return saveState
	end
	return nil
end

function PluginFacade.HotReloadPlugin(self: PluginFacade)
	local saveState = self:UnloadPlugin()
	PluginFacade._currentRoot = self._source:Clone()

	self:LoadPlugin(saveState)
end

function PluginFacade.WatchInstanceForChanges(self: PluginFacade, instance)
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
