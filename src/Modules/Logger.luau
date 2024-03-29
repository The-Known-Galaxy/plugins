local Config = require(script.Parent.Parent.Config)
--[=[
    @class Logger
    
    Generic output logger module.
]=]

local Logger = {}

--[=[
    @private

    Takes a logger function and logs the given text with it somewhere, prefixing by plugin name (so you know where the output is from).
]=]
function Logger.output(logFunction: typeof(print), text: string)
	return logFunction(`[{Config.Name.Short}]: {text}`)
end

--[=[
    Prints text to output. Nothing special.
]=]
function Logger.Print(text: string)
	return Logger.output(print, text)
end

--[=[
    Prints the given text as a yellow warning to output.
]=]
function Logger.Warn(text: string)
	return Logger.output(warn, text)
end

return Logger
