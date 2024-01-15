local create_augroup = function(group, opts)
	opts = opts or { clear = true }
	return vim.api.nvim_create_augroup(group, opts)
end

local autocmd = vim.api.nvim_create_autocmd

local M = {}

M.term_buf_autocmd = function(runner_bufwin_ids, group_name)
	local runner_bufnr = runner_bufwin_ids.bufnr
	local terminal = create_augroup("CoderunnerTerminalLocalOptions")
	autocmd({ "TermOpen" }, {
		group = terminal,
		pattern = { "*" },
		callback = function(event)
			if event.buf ~= runner_bufnr then
				return
			end
			vim.opt_local.number = false
			vim.opt_local.relativenumber = false
			vim.opt_local.cursorline = false
			vim.opt_local.signcolumn = "no"
			vim.opt_local.statuscolumn = ""
			local code_term_esc = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true)
			for _, key in ipairs({ "h", "j", "k", "l" }) do
				vim.keymap.set("t", "<C-" .. key .. ">", function()
					local code_dir = vim.api.nvim_replace_termcodes("<C-" .. key .. ">", true, true, true)
					vim.api.nvim_feedkeys(code_term_esc .. code_dir, "t", true)
				end, { noremap = true })
			end
			if vim.bo.filetype == "" then
				vim.cmd.startinsert()
			end
		end,
	})
	autocmd({ "WinEnter" }, {
		group = terminal,
		pattern = { "*" },
		callback = function(event)
			if event.buf ~= runner_bufnr then
				return
			end
			if vim.bo.filetype == "coderunner" then
				vim.cmd.startinsert()
			end
		end,
	})
	autocmd({ "TermClose", "WinClosed" }, {
		group = terminal,
		pattern = { "*" },
		callback = function(event)
			if event.buf ~= runner_bufnr then
				return
			end
			create_augroup(group_name, { clear = true })
		end,
	})
end

return M
