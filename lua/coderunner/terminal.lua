local ft, fn, api, au = vim.bo.filetype, vim.fn, vim.api, vim.api.nvim_create_autocmd

local M = {}

local create_augroup = function(group, opts)
	opts = opts or { clear = true }
	return api.nvim_create_augroup(group, opts)
end

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

local write_run_autocmd = function(term_cmds, terminal, bufwin_ids, group_name)
	local cur_file = fn.expand("%:p")
	local bufnr = api.nvim_get_current_buf()
	local function send_to_term(cmds, term)
		for _, cmd in ipairs(cmds) do
			send_to_terminal(term, cmd)
		end
	end
	local au_write = create_augroup(group_name)
	au("BufWritePost", {
		group = au_write,
		pattern = cur_file,
		callback = function(event)
			if event.buf ~= bufnr then
				return
			end
			send_to_term(term_cmds, terminal)
		end,
	})
	au({ "WinClosed" }, {
		group = au_write,
		callback = function(event)
			if event.buf ~= bufwin_ids.bufnr or event.match ~= tostring(bufwin_ids.winnr) then
				return
			end
			create_augroup(group_name)
		end,
	})
	send_to_term(term_cmds, terminal)
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

local build_cmd_text = function(cmd_tbl)
	local parsed_cmd_tbl = {}
	for _, cmd in ipairs(cmd_tbl) do
		table.insert(parsed_cmd_tbl, parse_cmd(cmd))
	end
	return parsed_cmd_tbl
end

M.send = function(bufwin_ids, cmd_tbl, group_name)
	local cmd_text = build_cmd_text(cmd_tbl)
	local terminal = get_terminal(bufwin_ids.bufnr)
	if not terminal or #cmd_tbl == 0 then
		return nil
	end

	local term_cmds = {}
	for _, cmd in ipairs(cmd_text) do
		table.insert(term_cmds, table.concat(cmd, " "))
	end
	write_run_autocmd(term_cmds, terminal, bufwin_ids, group_name)
	return true
end
return M
