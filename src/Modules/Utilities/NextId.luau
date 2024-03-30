--[=[
	@class NextId

	Provides a way to create a callback that always returns a Unique Identifier, or UID for short, in the form of an infinitely incrementing natural number.
	Inspired by the brilliant justification from [here](https://blog.boyned.com/articles/things-i-learned-using-react/) (CTRL+F `Don't type layout orders by hand`).
	Thanks [Kampfkarren](https://github.com/Kampfkarren)!
]=]
local NextId = {}

--[=[
	Returns a callback that can be used to freely create a new, unique identification number by invoking it.

	```lua
	local nextUniqueId = NextId.New()

	print(nextUniqueId()) --> 1
	print(nextUniqueId()) --> 2
	print(nextUniqueId()) --> 3
	```
]=]
function NextId.New(): () -> number
	local id = 0
	return function(): number
		id += 1
		return id
	end
end

return NextId
