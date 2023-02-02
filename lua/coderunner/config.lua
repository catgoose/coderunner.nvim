local M = {
	opts = {
		dev = false,
		langs = {
			ruby = {
				cmd = "ruby",
				-- cmd_args = "-w",
				cmd_args = "",
				args = "",
			},
			lua = {
				cmd = "lua",
				cmd_args = "",
				args = "",
			},
			javascript = {
				cmd = "node",
				cmd_args = "",
				args = "",
			},
			python = {
				cmd = "python3",
				cmd_args = "",
				args = "",
			},
		},
		split = "horizontal",
		scale = 0.25,
		filetype = "coderunner",
		cursor = {
			lastline = true,
		},
	},
}

local dev = function()
	require("coderunner.utils").dev()
end

M.init = function(opts)
	opts = opts or {}
	M.opts = vim.tbl_deep_extend("keep", opts, M.opts)
	if M.opts.dev then
		dev()
	end
	return M.opts
end

return M
