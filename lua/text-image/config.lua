---@mod text-image.config

local clients = require("text-image.clients")

---@class Config
---@field client? (string | ClientMakeCommand) The client that

---@type Config
local default_config = {
	client = "__detect", -- This value will use the client auto-detect feature
}

local config = {
	---@type Config
	value = vim.tbl_deep_extend("force", {}, default_config),
}

---@private
---@param user_config Config
function config.init(user_config)
	local value = vim.tbl_deep_extend("force", config.value, user_config)

	if value.client == "__detect" or not value.client then
		value.client = clients.detect_client()
	end

	if type(value.client) == "string" then
		value.client = clients.get_client_make_command(value.client)
	end

	config.value = value
end

return config
