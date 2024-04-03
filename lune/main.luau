local process = require("@lune/process")
local fs = require("@lune/fs")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")

local Util = require("lib/Util")
local Out = require("lib/Out")
local remodel = require("remodel")

if process.os ~= "windows" then
	error("Functionality for non-Windows systems has not been implemented yet.")
end

local TEST_PLACE_NAME = "test"
local ASSET_IMPORT_FILE_FORMAT = ".rbxm"

type ActionTree = {
	message: string,
	[string]: ActionTree | any,
}
local ProgramActions: ActionTree = {
	message = "What would you like to do?",
	build = {
		message = "What would you like to build?",
	},
	run = {
		message = "What would you like to run?",
	},
	import = {
		message = "What would you like to import?",
	},
}

--[=[
    Builds the place in which to test plugin execution.
]=]
function ProgramActions.build.place(placeNameOverride: string?)
	Out.Info("building place...")
	local placeName = if placeNameOverride then placeNameOverride else "place"
	local fullPlacePath = `build/{placeName}.rbxl`
	local projectFilePath = "place.project.json"
	local result = process.spawn("rojo", { "build", "--output", fullPlacePath, projectFilePath })
	if result.ok then
		Out.Info(`built {fullPlacePath} from {projectFilePath}`)
		Out.Success("place built!")
		return true
	else
		Out.Warn("Something went wrong while building place...")
		print(result.stderr)
		return false
	end
end

--[=[
    Builds the plugin directly into the Studio plugin folder on the current operating system.
]=]
function ProgramActions.build.plugin()
	local pluginOutputPath = Util.GetLocalPluginPath()
	if pluginOutputPath == nil then
		Out.Warn("no APPDATA environment variable")
		return false
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
		return true
	end
	return false
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
	local pluginPath = Util.GetLocalPluginPath()
	if pluginPath == nil then
		Out.Warn("plugin path could not be established! likely because APPDATA is missing")
		return false
	end

	if not fs.isFile(pluginPath) then
		Out.Success("plugin doesn't exist! nothing to remove!")
		return true
	else
		Out.Info("plugin found")
		local ok, _result = pcall(fs.removeFile, pluginPath)
		if ok then
			Out.Success("local plugin successfully removed!")
			return true
		else
			Out.Warn("local plugin not removed due to IO problems...")
			return false
		end
	end
end

--[=[
	Syncs all images used by the plugin with Tarmac into ROBLOX asset servers (uploads them).
]=]
function ProgramActions.sync_images()
	Out.Info("syncing all image assets to ROBLOX...")
	local result = process.spawn("tarmac", { "sync", "--auth", roblox.getAuthCookie(true), "--target", "roblox" })
	if result.ok then
		print(result.stdout)
		Out.Success("Images successfully synced!")
		return true
	else
		print(result.stderr)
		Out.Warn("Something went wrong...")
		return false
	end
end

--[=[
	Deploys the plugin to an existing asset ID, making it go LIVE.
]=]
function ProgramActions.deploy()
	local config = require("../src/Config")
	if config.DevelopmentMode == true then
		Out.Warn(
			`cannot deploy since {stdio.color("blue")}Config.DevelopmentMode{stdio.color(Out.TYPE.WARNING.color)} is turned on! aborting...`
		)
		return false
	end

	local confirmedDeploy = stdio.prompt("confirm", "are you sure you want to deploy?", false)
	if not confirmedDeploy then
		Out.Info("aborting deployment...")
		return false
	end

	local deploymentDirectory = "build/deploy"
	if not fs.isDir(deploymentDirectory) then
		Out.Info("creating deployment directory...")
		fs.writeDir(deploymentDirectory)
	end

	Out.Info("building plugin for deployment...")
	local pluginOutput = `{deploymentDirectory}/plugin.rbxm`
	local result = process.spawn("rojo", {
		"build",
		"--output",
		pluginOutput,
		"plugin.project.json",
	})
	if not result.ok then
		Out.Warn("Something went wrong!")
		print(result.stderr)
		return false
	end

	-- taking 1st array index since it returns an array of Instances, but we'll only ever have 1 instance in said array
	Out.Info("reading generated plugin file...")
	local pluginInstance = remodel.readModelFile(pluginOutput)[1]
	Out.Info("overwriting existing model asset in ROBLOX Marketplace...")
	local ok, writingResult = pcall(remodel.writeExistingModelAsset, pluginInstance, 16915363791)
	if ok then
		Out.Success("deployment finished!")
		return true
	else
		Out.Warn("something went wrong during overwriting!")
		print(writingResult)
		return false
	end
end

function ProgramActions.run.unit_tests()
	local ok = ProgramActions.build.place(TEST_PLACE_NAME)

	if not ok then
		return false
	end

	Out.Info("running unit tests...")
	local fullTestPlaceName = `build/{TEST_PLACE_NAME}.rbxl`
	local result = process.spawn("run-in-roblox", { "--place", fullTestPlaceName, "--script", "run-unit-tests.luau" })
	if result.ok then
		Out.Success("unit tests successfully ran!")
		print(result.stdout)
	else
		Out.Warn("something went wrong while running unit tests...")
		print(result.stdout)
		print(result.stderr)
	end

	Out.Info("cleaning up...")
	if fs.isFile(fullTestPlaceName) then
		fs.removeFile(fullTestPlaceName)
	end
	Out.Success("cleaned up successfully!")

	return result.ok
end

function ProgramActions.run.static_analysis()
	Out.Info("running selene's static analysis on codebase...")
	local result = process.spawn("selene", { "--display-style", "Rich", "src", "lune" })
	if result.ok then
		print(result.stdout)
		Out.Success("no problems in codebase!")
	else
		print(result.stdout)
		Out.Warn("there are problems you should deal with...")
	end

	return result.ok
end

--[=[
	Reads the local studio place file and imports all models from Workspace into a mirrored folder structure here.
	Useful for saving any plugin testing assets, and rojo-syncing them back in.

	It is advised to do this when Live-Sync is off.
	MeshId's don't get synced in.
]=]
function ProgramActions.import.local_testing_assets()
	Out.Info("importing testing assets from the local place instance...")
	local testingAssetPath = "assets/testing-models"
	if fs.isDir(testingAssetPath) then
		Out.Info("found and deleting old assets directory...")
		fs.removeDir(testingAssetPath)
	end

	fs.writeDir(testingAssetPath)

	local testingPlacePath = "build/place.rbxl"
	if not fs.isFile(testingPlacePath) then
		Out.Warn(`could not find [{testingPlacePath}]. aborting asset import`)
		return false
	end

	local nextId = require("../src/Modules/Utilities/NextId").New()

	-- recursively writes model files from the given Roblox Instance.
	local function recursivelyWriteModelFiles(path: string, instance: roblox.Instance)
		if instance.ClassName == "Folder" then
			local folderPath = `{path}/{instance.Name}`

			if fs.isDir(folderPath) then
				folderPath ..= nextId()
			end

			for _, child in instance:GetChildren() do
				recursivelyWriteModelFiles(folderPath, child)
			end
		else
			local modelPath = `{path}/{instance.Name}{ASSET_IMPORT_FILE_FORMAT}`
			if fs.isFile(modelPath) then
				modelPath = `{path}/{instance.Name}{nextId()}{ASSET_IMPORT_FILE_FORMAT}`
			end

			if not fs.isDir(path) then
				fs.writeDir(path)
			end

			Out.Info(`importing [{instance:GetFullName()}] to [{modelPath}]`)
			remodel.writeModelFile(modelPath, instance)
		end
	end

	Out.Info("reading place file...")
	local dataModel: roblox.DataModel = remodel.readPlaceFile(testingPlacePath)

	Out.Info("running recursive imports on all workspace children...")
	for _, child in dataModel:GetService("Workspace"):GetChildren() do
		if not (child.ClassName == "Terrain" or child.ClassName == "Camera") then
			recursivelyWriteModelFiles(testingAssetPath, child)
		end
	end

	Out.Success("successfully imported all local testing assets!")
	return true
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
