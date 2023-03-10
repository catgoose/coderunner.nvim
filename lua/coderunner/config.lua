local M = {
	opts = {
		dev = false,
		langs = {
			ruby = {
				cmd = { "ruby", "[#file]" },
			},
			lua = {
				cmd = { "lua", "[#file]" },
			},
			javascript = {
				cmd = { "node", "[#file]" },
			},
			python = {
				cmd = { "python3", "[#file]" },
			},
			cpp = {
				{ "make", { "[#ask]", "Enter make argument" } },
				{ "[#ask]", "Enter command to run" },
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
