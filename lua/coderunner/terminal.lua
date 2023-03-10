local ft, fn, api, au = vim.bo.filetype, vim.fn, vim.api, vim.api.nvim_create_autocmd
local u = require("coderunner.utils")
local aug = u.create_augroup

local M = {}

local function get_terminal(bufnr)
	local terminal_chan_id = nil
	for _, chan in pairs(vim.api.nvim_list_chans()) do
		if chan["mode"] == "terminal" and chan["buffer"] == bufnr then
			terminal_chan_id = chan["id"]
		end
	end
	return terminal_chan_id
end

local send_to_terminal = function(terminal_chan, term_cmd_text)
	vim.api.nvim_chan_send(terminal_chan, term_cmd_text .. "\n")
end

local parse_cmd = function(cmd)
	local cmds = {}
	for _, c in pairs(cmd) do
		if type(c) == "string" then
			if c == "[#file]" then
				table.insert(cmds, vim.fn.expand("%:t"))
			else
				table.insert(cmds, c)
			end
		end
		if type(c) == "table" then
			if c[1] == "[#ask]" then
				local input = vim.fn.input(c[2] .. ": ")
				table.insert(cmds, input)
			end
		end
	end
	return cmds
end

local build_cmd_text = function(lang)
	local cmd_tbl = {}
	for _, cmd in ipairs(lang) do
		table.insert(cmd_tbl, parse_cmd(cmd))
	end
	return cmd_tbl
end

local write_run_autocmd = function(term_cmds, terminal)
	local cur_file = fn.expand("%:p")
	local bufnr = api.nvim_get_current_buf()
	local function send_to_term(cmds, term)
		for _, cmd in ipairs(cmds) do
			send_to_terminal(term, cmd)
		end
	end
	local autocmd_group_name = "CodeRunnerOnBufWrite" .. cur_file .. ft .. api.nvim_get_current_win()
	au("BufWritePost", {
		group = aug(autocmd_group_name),
		pattern = cur_file,
		callback = function(event)
			if event.buf ~= bufnr then
				return
			end
			send_to_term(term_cmds, terminal)
		end,
	})
	send_to_term(term_cmds, terminal)
end

M.send = function(bufnr)
	local config = require("coderunner.config").opts
	local lang = config.langs[ft]
	if lang == nil then
		vim.notify("No runner found for filetype: " .. ft, vim.log.levels.WARN)
		return nil
	end

	local cmds = build_cmd_text(lang)
	local terminal = get_terminal(bufnr)
	if not terminal or #cmds == 0 then
		return nil
	end

	local term_cmds = {}
	for _, cmd in ipairs(cmds) do
		table.insert(term_cmds, table.concat(cmd, " "))
	end
	write_run_autocmd(term_cmds, terminal)
	return true
end
return M
