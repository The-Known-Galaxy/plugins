--[=[
    @class Out
    
    Output logger for custom terminal output logging.
]=]

local stdio = require("@lune/stdio")

local Out = {
	TYPE = {
		SUCCESS = { text = "SUCC", color = "green" },
		INFO = { text = "INFO", color = "white" },
		WARNING = { text = "WARN", color = "yellow" },
	},
}

function Out._out(type, text: string)
	print(
		`[{stdio.color(type.color)}{type.text}{stdio.color("reset")}]: {stdio.color(type.color)}{text}{stdio.color(
			"reset"
		)}`
	)
end

function Out.Info(text: string)
	Out._out(Out.TYPE.INFO, text)
end

function Out.Warn(text: string)
	Out._out(Out.TYPE.WARNING, text)
end

function Out.Success(text: string)
	Out._out(Out.TYPE.SUCCESS, text)
end

return Out
