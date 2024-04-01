--[=[
    @class Logger
    
    Generic output logger module.
]=]
local Config = require(script.Parent.Parent.Config)
local Logger = {}

--[=[
    @since 0.2.0 
    Formats a given text with the desired logging format of this plugin framework.
]=]
function Logger.Format(text: string): string
	return `[{Config.Name.Short}]: {text}`
end

--[=[
    @private
    @since 0.1.0 
    Takes a logger function and logs the given text with it somewhere, prefixing by plugin name (so you know where the output is from).
]=]
function Logger.output(logFunction: (input: string) -> ...any, text: string): ...any
	return logFunction(Logger.Format(text))
end

--[=[
    @since 0.1.0
    Prints text to output. Nothing special.
]=]
function Logger.Print(text: string): ...any
	return Logger.output(print, text)
end

--[=[
    @since 0.1.0
    Prints the given text as a yellow warning to output.
]=]
function Logger.Warn(text: string): ...any
	return Logger.output(warn, text)
end

--[=[
    @error string
    @since 0.1.0
    Logs the text as an error, but also actually errors.
]=]
function Logger.Error(text: string): ()
	Logger.output(error, text)
end

return Logger
