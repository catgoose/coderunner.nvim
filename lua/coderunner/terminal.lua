local ft = vim.bo.filetype
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

M.send = function(bufnr)
	local config = require("coderunner.config").opts
	local lang = config.langs[ft]
	if lang == nil then
		return nil
	end

	local cmd_text = "ls"
	vim.pretty_print(config)

	local terminal = get_terminal(bufnr)
	if not terminal then
		return nil
	end

	-- if not cmd_text then
	-- 	vim.ui.input({ prompt = "Send to terminal: " }, function(input_cmd_text)
	-- 		if not input_cmd_text then
	-- 			return nil
	-- 		end
	-- 		send_to_terminal(terminal, input_cmd_text)
	-- 	end)
	-- else
	send_to_terminal(terminal, cmd_text)
	-- end
	return true
end
return M
