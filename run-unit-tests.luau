local ServerScriptService = game:GetService("ServerScriptService")
local TestEZ = require(ServerScriptService.TKGSuite.Runner.Packages.TestEZ)

--[=[
	Finds all the children of all the `roots`, and returns an array of them where the children with the names present in `exclude` are removed.
]=]
local function filterRoots(roots: { Instance }, exclude: { string }): { Instance }
	local filteredRoots = {}
	local blacklist = {}

	for _, exclusion in ipairs(exclude) do
		blacklist[exclusion] = true
	end

	for _, root in ipairs(roots) do
		for _, child in ipairs(root:GetChildren()) do
			if not blacklist[child.Name] then
				table.insert(filteredRoots, child)
			end
		end
	end

	return filteredRoots
end

-- running tests
local results = TestEZ.TestBootstrap:run(filterRoots({ ServerScriptService }, { "Packages" }))

-- warning for bad results
if #results.errors > 0 or results.failureCount > 0 then
	warn("One or more tests failed")
end
