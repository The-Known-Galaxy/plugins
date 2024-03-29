local process = require("@lune/process")
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local Path = require("lib/Path")
local Out = require("lib/Out")

if process.os ~= "windows" then
	error("Functionality for non-Windows systems has not been implemented yet.")
end

type ActionTree = {
	message: string,
	[string]: ActionTree | any,
}
local ProgramActions: ActionTree = {
	message = "What would you like to do?",
	build = {
		message = "What would you like to build?",
	},
}

--[=[
    Builds the place in which to test plugin execution.
]=]
function ProgramActions.build.place()
	Out.Info("building place...")
	local result = process.spawn("rojo", { "build", "--output", "build/place.rbxl", "place.project.json" })
	if result.ok then
		Out.Success("place built!")
	else
		Out.Warn("Something went wrong while building place...")
		print(result.stderr)
	end
end

--[=[
    Builds the plugin directly into the Studio plugin folder on the current operating system.
]=]
function ProgramActions.build.plugin()
	local appDataDirectory = process.env.APPDATA
	if appDataDirectory ~= nil and appDataDirectory ~= "" then
		Out.Info("building plugin into Studio plugin directory...")
		local pluginOutputPath =
			Path.Join(appDataDirectory:gsub("Roaming", "Local"), "Roblox", "Plugins", "TKGSuite.rbxmx")
		if fs.isFile(pluginOutputPath) then
			Out.Info("existing plugin file found. deleting...")
			fs.removeFile(pluginOutputPath)
		end
		local result = process.spawn("rojo", {
			"build",
			"--output",
			pluginOutputPath,
			"plugin.project.json",
		})

		if result.ok then
			Out.Success("plugin building successful!")
		end
	else
		Out.Warn("no APPDATA environment variable")
	end
end

--[=[
    Walks a given `ActionTree` and executes their actions.
]=]
local function WalkActionTree(root: ActionTree)
	local options = {}
	local message
	for key, value in root do
		if key ~= "message" then
			table.insert(options, key)
		else
			message = value
		end
	end

	local quitString = stdio.color("red") .. "quit" .. stdio.color("reset")
	table.insert(options, quitString)

	local chosenOption
	repeat
		chosenOption = stdio.prompt("select", message, options)
		if chosenOption == nil then
			Out.Warn("You must choose an option!")
		end
	until chosenOption ~= nil
	local optionString = options[chosenOption]

	if optionString == quitString then
		process.exit(0)
	end

	local choice = root[optionString]

	if type(choice) == "table" then
		WalkActionTree(choice)
	elseif type(choice) == "function" then
		choice()
	end
end

-- main program entry point
WalkActionTree(ProgramActions)
