local cnf = require("coderunner.config")

local M = {}

M.setup = function(config)
	config = config or {}
	cnf.init(config)
end

M.run = function(config)
	config = config or {}
	require("coderunner.runner").run(config)
end

return M
