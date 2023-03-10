local u = require("coderunner.utils")
local au = require("coderunner.autocmd")
local term = require("coderunner.terminal")
local fn, api = vim.fn, vim.api
local M = {}

M.run = function(args)
	args = args or {}
	local config = require("coderunner.config").opts
	args.split = args.split or config.split
	args.scale = args.scale or config.scale

	local winnr = api.nvim_get_current_win()
	local runner_bufwin_ids = u.open_coderunner_win({
		split = args.split,
		scale = args.scale,
		filetype = config.filetype,
	})
	local runner_bufnr = runner_bufwin_ids.bufnr

	fn.win_gotoid(winnr)

	term.send(runner_bufnr)
end

return M
