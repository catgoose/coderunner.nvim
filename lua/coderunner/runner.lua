local u = require("coderunner.utils")
local au = require("coderunner.autocmd")
local fn, api, cmd, ft = vim.fn, vim.api, vim.cmd, vim.bo.filetype
local M = {}

M.run = function(args)
	args = args or {}
	local config = require("coderunner.config").opts
	args.split = args.split or config.split
	args.scale = args.scale or config.scale

	local lang = config.langs[ft]

	if lang == nil then
		return
	end

	local cur_file = fn.expand("%:p")
	local runner = { lang.cmd }
	local cmd_str = lang.cmd
	if lang.cmd_args ~= "" then
		for _, arg in ipairs(vim.split(lang.cmd_args, " ")) do
			table.insert(runner, arg)
		end
		cmd_str = cmd_str .. " " .. lang.cmd_args
	end
	table.insert(runner, cur_file)
	cmd_str = cmd_str .. " " .. fn.expand("%:t")
	if lang.args ~= "" then
		for _, arg in ipairs(vim.split(lang.args, " ")) do
			table.insert(runner, arg)
		end
		cmd_str = cmd_str .. " " .. lang.args
	end
	local winnr = api.nvim_get_current_win()

	local _, runner_bufnr = u.open_coderunner_win({
		split = args.split,
		scale = args.scale,
		filetype = config.filetype,
	})
	fn.win_gotoid(winnr)

	au.write_highlights(cmd_str, runner, runner_bufnr, winnr, cur_file, config)
	cmd.write()
end

return M
