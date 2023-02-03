local api, au, ft, fn = vim.api, vim.api.nvim_create_autocmd, vim.bo.filetype, vim.fn
local u = require("coderunner.utils")
local aug = u.create_augroup

local M = {}

local coderunner_augroup_name = "CodeRunnerQToQuit"

local q_quit = function()
	local config = require("coderunner.config").opts
	au({ "FileType" }, {
		group = aug(coderunner_augroup_name),
		pattern = config.filetype,
		callback = function(event)
			vim.bo[event.buf].buflisted = false
			vim.api.nvim_buf_set_keymap(event.buf, "n", "q", [[<cmd>close<cr>]], { noremap = true, silent = true })
		end,
	})
end

M.write_highlights = function(cmd_runner, runner_bufwin_ids)
	local cur_file = fn.expand("%:p")
	local autocmd_group_name = "CodeRunnerOnBufWrite" .. cur_file .. ft .. api.nvim_get_current_win()
	local runner_bufnr = runner_bufwin_ids.bufnr
	au("BufWritePost", {
		group = aug(autocmd_group_name),
		pattern = cur_file,
		callback = function()
			local banner = { ">> " .. cmd_runner.cmd_str, "" }
			local highlight = { stderr = "ErrorMsg", stdout = "TermCursorNC" }
			api.nvim_buf_set_lines(runner_bufnr, 0, -1, false, banner)
			u.add_highlight_to_range(runner_bufnr, -1, "DiagnosticHint", 0, #banner)
			local output_lines = function(_, data, name)
				if data then
					api.nvim_buf_set_lines(runner_bufnr, -1, -1, false, data)
					local last_line = api.nvim_buf_line_count(runner_bufnr)
					u.add_highlight_to_range(runner_bufnr, -1, highlight[name], last_line - #data, last_line)
					if require("coderunner.config").opts.cursor.lastline then
						api.nvim_win_set_cursor(runner_bufwin_ids.winnr, { last_line, 0 })
					end
				end
			end
			fn.jobstart(cmd_runner.runner, {
				stdout_buffered = true,
				stderr_buffered = true,
				on_stdout = output_lines,
				on_stderr = output_lines,
			})
		end,
	})
end

M.init = function()
	q_quit()
end

return M
