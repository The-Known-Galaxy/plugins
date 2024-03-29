local process = require("@lune/process")
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")

local Util = require("lib/Util")
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
	local pluginOutputPath = Util.GetLocalPluginPath()
	if pluginOutputPath == nil then
		Out.Warn("no APPDATA environment variable")
		return
	end

	Out.Info("building plugin into Studio plugin directory...")
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
end

--[=[
	Builds the plugin, the build place, and then starts the place instance that was just built.
]=]
function ProgramActions.build.plugin_and_place()
	ProgramActions.build.plugin()
	ProgramActions.build.place()
end

--[=[
	Removes the plugin file from the local Studio plugin folder, so it doesn't get in the way of using the actual plugin.
]=]
function ProgramActions.build.remove_plugin()
	Out.Info("removing local plugin...")

	local pluginPath = Util.GetLocalPluginPath()
	if pluginPath == nil then
		Out.Warn("plugin path could not be established! likely because APPDATA is missing")
		return
	end

	if not fs.isFile(pluginPath) then
		Out.Success("plugin doesn't exist! nothing to remove!")
		return
	else
		Out.Info("plugin found")
		local ok, _result = pcall(fs.removeFile, pluginPath)
		if ok then
			Out.Success("plugin successfully removed!")
		else
			Out.Warn("plugin not removed due to IO problems...")
		end
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

	table.sort(options)

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
