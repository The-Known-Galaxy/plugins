--!strict
--[=[
    @class ComponentVisualiser

    Provides functionality to visualise components.
    Currently only WorldRegions which are NamedAreas.
]=]
local NamedAreaVisualiser = require(script.NamedAreaVisualiser)
local Config = require(script.Parent.Parent.Config)
local Logger = require(script.Parent.Parent.Modules.Logger)
local Permissions = require(script.Parent.Parent.Modules.Permissions)
local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)
local SubModuleManager = require(script.Parent.Parent.Modules.SubModuleManager)
local images = require(script.Parent.Parent.Parent.Assets.images)
local Janitor = require(script.Parent.Parent.Parent.Libraries.Janitor)
local PluginFacade = require(script.Parent.Parent.PluginFacade)

local displayName = "Named Area Visualiser"
local pluginIcon = images.eye

local DEFAULT_VISUALISATION_STATE = false

local HiltSetProcessor = PluginSubModule.new({
	ButtonIcon = pluginIcon,
	DisplayName = displayName,
	Tooltip = "Handles visualisation of Named Areas",
	ActiveByDefault = false,
	OneClickExecution = true,
	DevelopmentModule = false,
})

local janitor
local visualisationEnabled = DEFAULT_VISUALISATION_STATE

local function onTrigger()
	visualisationEnabled = not visualisationEnabled
	NamedAreaVisualiser.ToggleVisuals(visualisationEnabled)
end

HiltSetProcessor:OnPreLoad(function(): (boolean, string?)
	if Permissions.GetAccessLevel().Level >= Permissions.AccessLevels.Contributor.Level then
		return true
	else
		return false, "Only Contributors can use the Component Visualiser."
	end
end)

HiltSetProcessor:OnPostLoad(
	function(pluginFacade: PluginFacade.PluginFacade, _manager: SubModuleManager.SubModuleManager): boolean?
		janitor = Janitor.new()
		-- bindable action (technically you can bind to the actual module button too, but other component visualisations will also come in the future)
		local visualiseNamedAreasAction = pluginFacade:CreatePluginAction(
			Config.ActionAndMenuId.ACTION_VISUALISE_NAMED_AREAS,
			"Toggle named area visualisations",
			"Visualises all named areas in the map by modifying their physical properties",
			pluginIcon,
			true
		)

		-- connecting to bindable event
		janitor:Add(visualiseNamedAreasAction.Triggered:Connect(function()
			onTrigger()
		end))

		-- toggling visualisation state for all objects initially
		local totalVisualisationState = NamedAreaVisualiser.AreVisualsEnabled()
		if totalVisualisationState == "partial" or totalVisualisationState ~= DEFAULT_VISUALISATION_STATE then
			local outputText
			if totalVisualisationState == "partial" then
				outputText = "NamedArea visualisations are partial."
			else
				outputText = "NamedArea visualisations differ from default."
			end

			Logger.Warn(`{outputText} {if DEFAULT_VISUALISATION_STATE then "Enabling" else "Disabling"} all visuals...`)
			NamedAreaVisualiser.ToggleVisuals(DEFAULT_VISUALISATION_STATE)
		end

		return true
	end
)

HiltSetProcessor:OnActivate(function(): boolean?
	onTrigger()
	return true
end)

HiltSetProcessor:OnPreUnload(function(): boolean?
	janitor:Destroy()
	return true
end)

return HiltSetProcessor
