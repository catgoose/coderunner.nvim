local term = require("coderunner.terminal")
local fn, api, cmd, o = vim.fn, vim.api, vim.cmd, vim.o
local M = {}

local set_opts = function(config, win, buf)
	api.nvim_set_option_value("number", false, { win = win })
	api.nvim_set_option_value("relativenumber", false, { win = win })
	if config.filetype then
		api.nvim_set_option_value("filetype", config.filetype, { buf = buf })
	end
	if config.split == "vertical" then
		api.nvim_win_set_width(win, math.floor(o.columns * config.scale))
	end
	if config.split == "horizontal" then
		api.nvim_win_set_height(win, math.floor(o.lines * config.scale))
	end
end

local open_split = function(config)
	local cur_winnr = api.nvim_get_current_win()
	local winnr = nil
	local bufnr = nil
	for _, win in ipairs(api.nvim_list_wins()) do
		local buf = api.nvim_win_get_buf(win)
		if api.nvim_get_option_value("filetype", { buf = buf }) == config.filetype then
			api.nvim_win_set_buf(win, buf)
			winnr = win
			bufnr = buf
		end
	end
	if winnr == nil then
		bufnr = api.nvim_create_buf(false, false)
		if config.split == "vertical" then
			cmd([[botright vsplit]])
		end
		if config.split == "horizontal" then
			cmd([[botright split]])
		end
		winnr = api.nvim_get_current_win()
		api.nvim_win_set_buf(winnr, bufnr)
		cmd.terminal()
		api.nvim_set_current_win(cur_winnr)
	end
	set_opts(config, winnr, bufnr)
	return winnr, bufnr
end

local open_coderunner_win = function(config)
	config = config or {}
	config.split = config.split or "vertical"
	config.scale = config.scale or 1
	local winnr, bufnr = open_split(config)
	return {
		winnr = winnr,
		bufnr = bufnr,
	}
end

local get_autocmd_group_name = function()
	local cur_file = fn.expand("%:p")
	local bufnr = api.nvim_get_current_buf()
	local winnr = api.nvim_get_current_win()
	local autocmd_group_name = "CodeRunnerOnBufWrite" .. cur_file .. vim.bo.filetype .. winnr .. bufnr
	return autocmd_group_name
end

M.run = function(args)
	args = args or {}
	local config = require("coderunner.config").opts

	local ft = vim.bo.filetype
	local cmd_tbl = config.langs[ft]
	if cmd_tbl == nil then
		vim.notify("No runner found for filetype: " .. ft, vim.log.levels.WARN)
		return nil
	end

	args.split = args.split or config.split
	args.scale = args.scale or config.scale

	local cur_winnr = api.nvim_get_current_win()
	local runner_bufwin_ids = open_coderunner_win({
		split = args.split,
		scale = args.scale,
		filetype = config.filetype,
	})

	local group_name = get_autocmd_group_name()
	require("coderunner.autocmd").term_buf_autocmd(runner_bufwin_ids, group_name)

	fn.win_gotoid(cur_winnr)

	term.send(runner_bufwin_ids, cmd_tbl, group_name)
end

return M
