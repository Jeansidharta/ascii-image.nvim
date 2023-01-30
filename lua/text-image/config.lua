---@mod text-image.config

local clients = require("text-image.clients")

---@class Config
---@field client? (string | ClientMakeCommand) The client that
---@field auto_open_on_image? boolean If true, will automatically display the image whenever the user opens an image file (such as .png, .jpg or .gif).

---@type Config
local default_config = {
	client = "__detect", -- This value will use the client auto-detect feature
	auto_open_on_image = false,
}

local config = {
	---@type Config
	value = vim.tbl_deep_extend("force", {}, default_config),
	---@type ClientMakeCommand | nil
	client = nil,
}

---@private
---@param user_config Config
function config.init(user_config)
	local value = vim.tbl_deep_extend("force", config.value, user_config)

	if value.client == "__detect" or not value.client then
		config.client = clients.detect_client()
		if not config.client then
			error("No client was provided, and no client could be detected")
		end
	end

	if type(value.client) == "string" then
		config.client = clients.get_client_make_command(value.client)
		if not config.client then
			error("The provided cleint does not exist")
		end
	end

	config.value = value
end

return config
