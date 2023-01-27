local clients = require("text-image.clients")

local default_config = {
	client = "__detect", -- This value will use the client auto-detect feature
}

local M = {}

--- Duplicate the default config
local config = vim.tbl_deep_extend("force", {}, default_config)

function M.init(user_config)
	config = vim.tbl_deep_extend("force", config, user_config)

	if config.client == "__detect" or not config.client then
		config.client = clients.detect_client()
	end

	if type(config.client) == "string" then
		config.client = clients.get_client_make_command(config.client)
	end
end

return setmetatable(M, {
	__index = function(_, key)
		print(key)
		return config[key]
	end,
})
