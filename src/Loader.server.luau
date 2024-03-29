if not plugin then
	error("Plugin source code must be executed as a plugin!")
end

print("hello world from TKG Suite")

local OtherModule = require(script.Parent.OtherModule)
print(OtherModule)
