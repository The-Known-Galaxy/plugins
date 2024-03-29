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

    newSubModule:OnPreLoad(function()
        -- only person with user id 456 can use this module!
        return StudioService:GetUserId() == 456
    end)

    newSubModule:OnActivate(function()
        print("I'm a plugin that logs a random number to console!")
        print(math.random(1, 10))
    end)

    reeturn newSubModule
    ```
]=]
local Config = require(script.Parent.Parent.Config)
local Llama = require(script.Parent.Parent.Parent.Libraries.Llama)

type PluginSubModuleImpl = {
	__index: PluginSubModuleImpl,
	new: (config: PluginSubModuleConfig) -> PluginSubModule,
	OnPreLoad: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
	OnPostLoad: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
	OnActivate: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
	OnDeactivate: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
	OnPreUnload: (self: PluginSubModule, executor: LifeCycleExecutor) -> (),
}

--[=[
    @type LifeCycleExecutor () -> boolean?
    @within PluginSubModule
    
    Executor function that is hooked into any of the life cycle events.
]=]
export type LifeCycleExecutor = () -> boolean?

--[=[
    @prop ButtonIcon string
    @within PluginSubModule
    @readonly

    The asset string for the icon of the button that activates/deactivates this submodule. 
]=]
--[=[
    @prop ActiveByDefault boolean
    @within PluginSubModule
    @readonly

    Whether the submodule is turned active immediately after loading.
]=]
--[=[
    @prop Active boolean 
    @within PluginSubModule
    @readonly
    
    Whether the plugin is currently active or not.
]=]
export type PluginSubModuleProperties = {
	ButtonIcon: string,
	ActiveByDefault: boolean,
	Active: boolean,
	_executors: {
		PreLoad: LifeCycleExecutor?,
		PostLoad: LifeCycleExecutor?,
		Activate: LifeCycleExecutor?,
		Deactivate: LifeCycleExecutor?,
		PreUnload: LifeCycleExecutor?,
	},
}
--[=[
    @interface PluginSubModuleConfig
    @within PluginSubModule
    
    .ButtonIcon string
    .ActiveByDefault boolean

    Supplied to the constructor to overwrite default module parameters.
]=]
export type PluginSubModuleConfig = {
	ButtonIcon: string,
	ActiveByDefault: boolean,
}
export type PluginSubModule = typeof(setmetatable({} :: PluginSubModuleProperties, {} :: PluginSubModuleImpl))

local PluginSubModule: PluginSubModuleImpl = {} :: PluginSubModuleImpl
PluginSubModule.__index = PluginSubModule

local DEFAULTS: PluginSubModuleProperties = {
	ButtonIcon = Config.MainIcon,
	ActiveByDefault = false,
	Active = false,
	_executors = {
		PreLoad = function(): boolean?
			return true
		end,
	},
}

--[=[
    @tag constructor 
    Creates a new PluginSubModule.
]=]
function PluginSubModule.new(config: PluginSubModuleConfig): PluginSubModule
	local properties = Llama.Dictionary.merge(DEFAULTS, {
		ButtonIcon = config.ButtonIcon,
		ActiveByDefault = config.ActiveByDefault,
	})

	local self = setmetatable(properties, PluginSubModule)

	return self
end

--[=[
    @tag methods
    Register a function that runs _before_ the submodule is about to **load**.
    Its returnvalue's truthyness is used to decide if the submodule should continue to load.
    If it does not load, then no other lifecycle methods run.

    This is the best place to do permission checks or other contextual checks against whether the rest of the module should run.
]=]
function PluginSubModule:OnPreLoad(executor: LifeCycleExecutor)
	self._executors.PreLoad = executor
end

--[=[
    @tag methods
    Register a function that runs _after_ the submodule has loaded.
    
    It is best to do any actual initialisation code in here.
    Declaring buttons, context actions, mounting UIs, etc.
]=]
function PluginSubModule:OnPostLoad(executor: LifeCycleExecutor)
	self._executors.PostLoad = executor
end

--[=[
    @tag methods
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
    Register a function that runs _before_ the submodule is about to **unload**.

    This has no practical usage in most production use-cases, since this hook is only invoked when the entire plugin's modules are unloaded and the plugin's execution is stopped.
    In other words, whenever **you are live testing it with [Config.DevelopmentMode] turned on (hot reloading) or when the end-user deactivates the plugin from the menu**
]=]
function PluginSubModule:OnPreUnload(executor: LifeCycleExecutor)
	self._executors.Deactivate = executor
end

return PluginSubModule
