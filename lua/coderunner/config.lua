local M = {
	opts = {
		dev = false,
		langs = {
			ruby = {
				cmd = { "ruby" },
			},
			lua = {
				cmd = { "lua" },
			},
			javascript = {
				cmd = { "node" },
			},
			python = {
				cmd = { "python3" },
			},
			cpr = {
				"make",
				{ "[#ask]", "Enter make argument" },
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
