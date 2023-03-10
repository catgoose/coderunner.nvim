local M = {
	opts = {
		dev = false,
		langs = {
			ruby = {
				{ "ruby", "[#file]" },
			},
			lua = {
				{ "lua", "[#file]" },
			},
			python = {
				{ "python3", "[#file]" },
			},
			javascript = {
				{ "clear" },
				{ "node", "[#file]" },
			},
			cpp = {
				{ "clear" },
				{ "make", { "[#ask]", "Enter make argument" } },
				{ { "[#ask]", "Command to run after make" } },
			},
		},
		split = "horizontal",
		scale = 0.25,
		filetype = "coderunner",
	},
}

M.init = function(opts)
	opts = opts or {}
	M.opts = vim.tbl_deep_extend("keep", opts, M.opts)
	return M.opts
end

return M
