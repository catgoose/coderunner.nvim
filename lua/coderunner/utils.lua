local api, cmd, o = vim.api, vim.cmd, vim.o
local M = {}

M.dev = function()
	P = function(...)
		local tbl = {}
		for i = 1, select("#", ...) do
			local v = select(i, ...)
			table.insert(tbl, vim.inspect(v))
		end

		print(table.concat(tbl, "\n"))
		return ...
	end
end

M.open_coderunner_win = function(config)
	config = config or {}
	config.split = config.split or "horizontal"
	config.scale = config.scale or 1
	local cur_winnr = api.nvim_get_current_win()
	local winnr = nil
	local bufnr = nil
	for _, win in ipairs(api.nvim_list_wins()) do
		local buf = api.nvim_win_get_buf(win)
		if api.nvim_buf_get_option(buf, "filetype") == config.filetype then
			api.nvim_win_set_buf(win, buf)
			winnr = win
			bufnr = buf
		end
	end
	if winnr == nil then
		bufnr = api.nvim_create_buf(false, false)
		if config.split == "horizontal" then
			cmd([[botright vsplit]])
		end
		if config.split == "vertical" then
			cmd([[botright split]])
		end
		winnr = api.nvim_get_current_win()
		api.nvim_win_set_buf(winnr, bufnr)
		api.nvim_set_current_win(cur_winnr)
	end
	api.nvim_win_set_option(winnr, "number", false)
	api.nvim_win_set_option(winnr, "relativenumber", false)
	api.nvim_buf_set_option(bufnr, "buftype", "nofile")
	if config.filetype then
		api.nvim_buf_set_option(bufnr, "filetype", config.filetype)
	end
	if config.split == "horizontal" then
		api.nvim_win_set_width(winnr, math.floor(o.columns * config.scale))
	end
	if config.split == "vertical" then
		api.nvim_win_set_height(winnr, math.floor(o.lines * config.scale))
	end
	return { winnr = winnr, bufnr = bufnr }
end

M.add_highlight_to_range = function(buf, ns, hl, start_line, end_line)
	for i = start_line, end_line do
		api.nvim_buf_add_highlight(buf, ns, hl, i, 0, -1)
	end
end

M.create_augroup = function(group, opts)
	opts = opts or { clear = true }
	return api.nvim_create_augroup(group, opts)
end

return M
