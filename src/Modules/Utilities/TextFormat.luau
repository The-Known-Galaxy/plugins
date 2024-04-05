--[=[
    @class TextFormat
    
    Formats text in ROBLOX [RichText markup](https://create.roblox.com/docs/ui/rich-text).
]=]

local TextFormat = {}

--[=[
    Turns text **bold**.
]=]
function TextFormat.Bold(text: string): string
	return `<b>{text}</b>`
end

--[=[
    Turns text *italics*.
]=]
function TextFormat.Italics(text: string): string
	return `<i>{text}</i>`
end

--[=[
    Turns text into a hyperlink like [this GitHub link](https://github.com/).
]=]
function TextFormat.Hyperlink(text: string): string
	local color = Color3.fromRGB(71, 74, 216)
	return `<u><font color="#{color:ToHex()}">{text}</font></u>`
end

return TextFormat
