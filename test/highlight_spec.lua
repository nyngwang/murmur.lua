describe("highlight", function()
	it("sanitizes properly", function()
		local highlight = require("murmur.utils.highlight")
		local sanitized = highlight.sanitize({
			foreground = "Normal",
			guibg = 0xff0000,
			special = "#00ff00",
			style = "italic",
			bold = true,
			undercurl = true,
		})
		assert(sanitized.fg == highlight.attr("Normal", "fg"), vim.inspect(sanitized))
		assert(sanitized.bg == "#ff0000", vim.inspect(sanitized))
		assert(sanitized.sp == "#00ff00", vim.inspect(sanitized))
		assert(sanitized.bold == true, vim.inspect(sanitized))
		assert(sanitized.italic == true, vim.inspect(sanitized))
		assert(sanitized.undercurl == true, vim.inspect(sanitized))
		assert(sanitized.foreground == nil, vim.inspect(sanitized))
	end)

	it("handles randomized inputs with hex numbers and highlight group names", function()
		local highlight = require("murmur.utils.highlight")

		-- Generate randomized hex colors
		local randomHexForeground = math.random(0, 0xFFFFFF)
		local randomHexSpecial = string.format("#%06x", math.random(0, 0xFFFFFF))

		-- Create a randomized input table with hex colors and highlight group names
		local randomizedInput = {
			foreground = randomHexForeground,
			background = "Normal",
			special = randomHexSpecial,
			style = "italic",
			gui = "bold",
			underline = false,
			undercurl = true,
		}

		local sanitized = highlight.sanitize(randomizedInput)

		-- Assert the output values
		assert(sanitized.fg == string.format("#%06x", randomHexForeground), vim.inspect(sanitized))
		assert(sanitized.bg == highlight.attr("Normal", "bg"), vim.inspect(sanitized))
		assert(sanitized.sp == randomHexSpecial, vim.inspect(sanitized))
		assert(sanitized.italic == true, vim.inspect(sanitized))
		assert(sanitized.underline == false, vim.inspect(sanitized))
		assert(sanitized.undercurl == true, vim.inspect(sanitized))
		assert(sanitized.bold == true, vim.inspect(sanitized))
	end)
end)
