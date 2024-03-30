return function()
	local NextId = require(script.Parent.NextId)

	describe("NextId", function()
		it("should load", function(_context)
			expect(NextId).to.be.ok()
		end)
	end)

	describe("New", function()
		it("should return a callback", function(_context)
			expect(NextId.New()).to.be.a("function")
		end)
	end)

	describe("New() callback", function()
		local callback = NextId.New()
		beforeEach(function()
			callback = NextId.New()
		end)

		it("should return a number", function(_context)
			expect(callback()).to.be.a("number")
		end)

		it("should start from 1", function()
			expect(callback()).to.equal(1)
		end)

		it("should return incrementing Natural numbers on repeat calls", function()
			local initial = callback()
			local second = callback()
			local third = callback()
			expect(second - initial).to.equal(1)
			expect(third - second).to.equal(1)
		end)
	end)
end
