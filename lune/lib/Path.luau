--[=[
    @class Path
    
    Simple library for manipulating paths.
]=]

local process = require("@lune/process")

local FILE_SEP = {
	windows = "\\",
	linux = "/",
	macos = "/",
}

local Path = {
	--[=[
        The file separator for this operating system.
    ]=]
	Separator = FILE_SEP[process.os],
}

--[=[
    Joins strings together into an OS-compliant path.
]=]
function Path.Join(...: string): string
	local path = ""
	local pathObjects = table.pack(...)
	for index, file in ipairs(pathObjects) do
		path ..= file .. if index < #pathObjects then Path.Separator else ""
	end
	return path
end

return Path
