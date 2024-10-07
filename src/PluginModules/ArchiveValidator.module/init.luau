--!strict
--[=[
    @class ArchiveValidator

    Validates the contents of the archives when they are selected.
]=]
local Selection = game:GetService("Selection")
local ServerStorage = game:GetService("ServerStorage")

local Logger = require(script.Parent.Parent.Modules.Logger)
local Permissions = require(script.Parent.Parent.Modules.Permissions)
local PluginSubModule = require(script.Parent.Parent.Modules.PluginSubModule)
local Llama = require(script.Parent.Parent.Parent.Libraries.Llama)
local ArchiveParser = require(script.Parent.Parent.TKGShared.ArchiveParser)

ArchiveParser.InjectDependencies(Llama)

local HiltSetProcessor = PluginSubModule.new({
	ButtonIcon = "rbxassetid://12663078719",
	DisplayName = "Archive Validator",
	Tooltip = "Validates the contents of the current place file's archives for any problems.",
	ActiveByDefault = false,
	OneClickExecution = true,
	DevelopmentModule = false,
})

local function validateArchives(folder: Folder)
	Logger.Print(`Validating... {folder:GetFullName()}`)
	local result = ArchiveParser.ParseArchivesToObject(folder, true)

	if result.Success then
		Logger.Print("Library valid! No problems to fix. Well done!")
		return
	end

	Logger.Warn(`{#result.Problems} problem{if #result.Problems == 1 then "" else "s"} were found after validation...`)
	local totalProblems = #result.Problems
	for problemIndex, problem in result.Problems do
		local problemMessage =
			`[{("%0" .. math.floor(math.log10(totalProblems * 10)) .. "d"):format(problemIndex)}/{totalProblems}] [{problem.Type}]: {problem.Message}`

		if problem.GameBreaking then
			Logger.Warn(`[CRIT] {problemMessage}`)
		else
			Logger.Print(`[    ] {problemMessage}`)
		end
	end
end

HiltSetProcessor:OnPreLoad(function(): (boolean, string?)
	if Permissions.GetAccessLevel().Level >= Permissions.AccessLevels.Contributor.Level then
		return true
	else
		return false,
			"Only permitted members of the Librarian's Assembly and Sphere of Ancient Knowledge can use the Archive Validator. Members must also be in the Archive Import group."
	end
end)

HiltSetProcessor:OnActivate(function(): boolean?
	-- first we check the selection
	local selection = Selection:Get()
	local libraryFromSelection = selection[1]
	if #selection == 1 and libraryFromSelection ~= nil and libraryFromSelection:IsA("Folder") then
		validateArchives(libraryFromSelection)
		return
	end

	local errorPrefix = "No library to validate."

	-- then we check the default library contents of the place
	-- looking for ServerStorage > MainLibrary > MainModule > LibraryContent
	local mainLibrary = ServerStorage:FindFirstChild("MainLibrary")
	if not mainLibrary or not mainLibrary:IsA("Folder") then
		Logger.Warn(`{errorPrefix} [ServerStorage > MainLibrary] does not exist.`)
		return
	end

	local mainModule = mainLibrary:FindFirstChildWhichIsA("ModuleScript")
	if not mainModule or mainModule.Name ~= "MainModule" then
		Logger.Warn(`{errorPrefix} [ServerStorage > MainLibrary > MainModule] does not exist.`)
		return
	end

	local defaultLibraryContent = mainModule:FindFirstChild("LibraryContent")
	if not defaultLibraryContent or not defaultLibraryContent:IsA("Folder") then
		Logger.Warn(`{errorPrefix} [Server Stirage > MainLibrary > MainModule > LibraryContent] does not exist.`)
		return
	end

	validateArchives(defaultLibraryContent)
	return
end)

return HiltSetProcessor
