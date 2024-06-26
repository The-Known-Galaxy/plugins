--!strict
--[=[
    @class PluginSubModule
    
    Every tool, submodule, and sub-plugin must be one of these.
    All custom behaviour is put into this.
    These are then loaded, activated, deactivated and unloaded (in other words, entirely managed) by [SubModuleManager].

    Intended use is something like this:
    ```lua
    local StudioService = game:GetService("StudioService")
    local PluginSubModule = require(script.path.to.PluginSubModule)

    local newSubModule = PluginSubModule.new({
        ButtonIcon = "rbxassetid://123",
        ActiveByDefault = true,
    })

    newSubModule:OnPreLoad(function(_pluginFacade: PluginFacade.PluginFacade)
        -- only person with user id 456 can use this module!
        return StudioService:GetUserId() == 456
    end)

    newSubModule:OnActivate(function(_pluginFacade: PluginFacade.PluginFacade)
        print("I'm a plugin that logs a random number to console!")
        print(math.random(1, 10))
    end)

    return newSubModule
    ```
]=]
local Config = require(script.Parent.Parent.Config)
local Llama = require(script.Parent.Parent.Parent.Libraries.Llama)
local PluginFacade = require(script.Parent.Parent.PluginFacade)
local NextId = require(script.Parent.Utilities.NextId)

type PluginSubModuleImpl = {
	__index: PluginSubModuleImpl,
	new: (config: PluginSubModuleConfig) -> PluginSubModule,
	OnPreLoad: (self: PluginSubModule, executor: PreLoadExecutor) -> (),
	OnPostLoad: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
	OnActivate: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
	OnDeactivate: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
	OnPreUnload: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
}

--[=[
    @type LifeCycleExecutor (pluginFacade: PluginFacade, manager: SubModuleManager) -> boolean?
    @within PluginSubModule
    
    Executor function that is hooked into any of the life cycle events.
    Access to the [PluginFacade] instance is provided to support whatever custom behaviour is desired.
]=]
export type LifeCycleExecutor = (pluginFacade: PluginFacade.PluginFacade, manager: any) -> boolean?

--[=[
    @type PreLoadExecutor (pluginFacade: PluginFacade) -> (boolean, string?)
    @within PluginSubModule
    
    Executor function that is hooked specifically into the PreLoad life cycle.
    Can optionally return a `string` explaining _why_ the module failed to load.
    Access to the [PluginFacade] instance is provided to support whatever custom behaviour is desired.
]=]
export type PreLoadExecutor = (pluginFacade: PluginFacade.PluginFacade, manager: any) -> (boolean, string?)

--[=[
    @prop ButtonIcon string
    @within PluginSubModule
    @readonly
    @since v0.1.0 

    The asset string for the icon of the [PluginToolbarButton] that activates/deactivates this submodule. 
]=]
--[=[
    @prop ActiveByDefault boolean
    @within PluginSubModule
    @readonly
    @since v0.1.0 

    Whether the submodule is turned active immediately after loading.
]=]
--[=[
    @prop Active boolean 
    @within PluginSubModule
    @readonly
    @since v0.1.0 
    
    Whether the plugin is currently active or not.
]=]
--[=[
    @prop DisplayName string 
    @within PluginSubModule
    @readonly
    @since v0.1.0 
    
    The display name of the submodule. Used in places like the [PluginToolbarButton] for the submodule.
]=]
--[=[
    @prop Tooltip string 
    @within PluginSubModule
    @readonly
    @since v0.1.0 
    
    A short description-like text for the submodule. Used in places like the [PluginToolbarButton] for the submodule.
]=]
--[=[
    @prop OneClickExecution boolean
    @within PluginSubModule
    @readonly
    @since v0.1.0 
    
    Whether the submodule's button should activate and then immediately deactivate the submodule - functioning like a single-click event.
    Both the `Activate` and `Deactivate` hooks will fire in their respective order.

    Useful for instances like "hey I want this submodule to do something small every time I click it".

    [PluginSubModule.ActiveByDefault] means this plugin will one-shot execute its functionality immediately when the Studio starts.
]=]
--[=[
    @prop DevelopmentModule boolean
    @within PluginSubModule
    @readonly
    @since v0.1.0 
    
    If true, then this submodule **only** loads when [PluginFacade.DevelopmentMode] is turned on.
    Useful for creating submodules intended entirely for testing or plugin development purposes.
]=]
--[=[
    @prop UID string
    @within PluginSubModule
    @readonly
    @since v0.1.0 
    
    A unique identifier for the submodule, meant for internal use.
]=]
export type PluginSubModuleProperties = {
	ButtonIcon: string,
	ActiveByDefault: boolean,
	Active: boolean,
	DisplayName: string,
	Tooltip: string,
	OneClickExecution: boolean,
	DevelopmentModule: boolean,
	UID: string,
	_executors: typeof(setmetatable(
		{},
		{} :: {
			PreLoad: PreLoadExecutor,
			PostLoad: LifeCycleExecutor?,
			Activate: LifeCycleExecutor?,
			Deactivate: LifeCycleExecutor?,
			PreUnload: LifeCycleExecutor?,
		}
	)),
}
--[=[
    @interface PluginSubModuleConfig
    @within PluginSubModule
    .ButtonIcon string?
    .ActiveByDefault boolean?
    .DisplayName string?
    .Tooltip string?
    .OneClickExecution: boolean?

    Supplied to the constructor to overwrite default module parameters.
]=]
export type PluginSubModuleConfig = {
	ButtonIcon: string?,
	ActiveByDefault: boolean?,
	DisplayName: string?,
	Tooltip: string?,
	OneClickExecution: boolean?,
	DevelopmentModule: boolean?,
}
export type PluginSubModule = typeof(setmetatable({} :: PluginSubModuleProperties, {} :: PluginSubModuleImpl))

local PluginSubModule: PluginSubModuleImpl = {} :: PluginSubModuleImpl
PluginSubModule.__index = PluginSubModule

local DEFAULT_EXECUTORS = {
	PreLoad = function(_pluginFacade: PluginFacade.PluginFacade): (boolean, string?)
		return true
	end,
}

local DEFAULTS = {
	ButtonIcon = Config.MainIcon,
	ActiveByDefault = false,
	Active = false,
	DisplayName = "Default Display Name",
	Tooltip = "Default tooltip",
	OneClickExecution = false,
	DevelopmentModule = false,
	UID = "",
	_executors = {},
}

local nextSubModuleId = NextId.New()
--[=[
    @tag constructor 
    @since v0.1.0 
    Creates a new PluginSubModule.
]=]
function PluginSubModule.new(config: PluginSubModuleConfig): PluginSubModule
	local properties: PluginSubModuleProperties = Llama.Dictionary.merge(DEFAULTS, {
		ButtonIcon = config.ButtonIcon,
		ActiveByDefault = config.ActiveByDefault,
		DisplayName = config.DisplayName,
		Tooltip = config.Tooltip,
		OneClickExecution = config.OneClickExecution,
		DevelopmentModule = config.DevelopmentModule,
	})

	properties.UID = tostring(nextSubModuleId())
	properties._executors = setmetatable({}, DEFAULT_EXECUTORS)

	local self = setmetatable(properties, PluginSubModule)

	return self
end

--[=[
    @tag methods
    @since v0.1.0 
    Register a function that runs _before_ the submodule is about to **load**.
    Its returnvalue's truthyness is used to decide if the submodule should continue to load.
    If it does not load, then no other lifecycle methods run.

    This is the best place to do permission checks or other contextual checks against whether the rest of the module should run.
]=]
function PluginSubModule:OnPreLoad(executor: PreLoadExecutor)
	self._executors.PreLoad = executor
end

--[=[
    @tag methods
    @since v0.1.0 
    Register a function that runs _after_ the submodule has loaded.
    
    It is best to do any actual initialisation code in here.
    Declaring buttons, context actions, mounting UIs, etc.
]=]
function PluginSubModule:OnPostLoad(executor: LifeCycleExecutor)
	self._executors.PostLoad = executor
end

--[=[
    @tag methods
    @since v0.1.0 
    Register a function that runs _after_ the submodule has been "activated".
    [PluginSubModule.Active] will be `true` at this point in time.

    It is best to start executing the module's main functionality from here, whatever it may be.
    Opening up widget UIs, running primary processing code, etc.
]=]
function PluginSubModule:OnActivate(executor: LifeCycleExecutor)
	self._executors.Activate = executor
end

--[=[
    @tag methods
    @since v0.1.0 
    Register a function that runs _after_ the submodule has been "deactivated".
    [PluginSubModule.Active] will be `false` at this point in time.

    It is best to pause/stop executing the module's main functionlity from here, whatever it may be.
    Closing widget UIs, pausing or stopping primary processing code, etc.
]=]
function PluginSubModule:OnDeactivate(executor: LifeCycleExecutor)
	self._executors.Deactivate = executor
end

--[=[
    @tag methods
    @since v0.1.0 
    Register a function that runs _before_ the submodule is about to **unload**.

    This has no practical usage in most production use-cases, since this hook is only invoked when the entire plugin's modules are unloaded and the plugin's execution is stopped.
    In other words, whenever **you are live testing it with [Config.DevelopmentMode] turned on (hot reloading) or when the end-user deactivates the plugin from the menu**
]=]
function PluginSubModule:OnPreUnload(executor: LifeCycleExecutor)
	self._executors.PreUnload = executor
end

return PluginSubModule
