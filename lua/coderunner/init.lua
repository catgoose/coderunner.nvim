local cnf = require("coderunner.config")

local M = {}

M.setup = function(config)
	config = config or {}
	cnf.init(config)
	vim.api.nvim_create_user_command("Coderunner", function()
		M.run()
	end, {})
	vim.api.nvim_create_user_command("CoderunnerHorizontal", function()
		M.run({ split = "horizontal" })
	end, {})
	vim.api.nvim_create_user_command("CoderunnerVertical", function()
		M.run({ split = "vertical" })
	end, {})
end

M.run = function(config)
	config = config or {}
	require("coderunner.runner").run(config)
end

return M
