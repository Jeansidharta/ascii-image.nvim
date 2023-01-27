local M = {}

-- TODO - add more clients
local client_make_command_dict = {
	["chafa"] = function(path, width, height)
		return "chafa " .. path .. " --size=" .. width .. "x" .. height
	end,
}

function M.detect_client()
	local has_client = vim.fn.executable

	for client_name, client_make_command in pairs(client_make_command_dict) do
		if has_client(client_name) then
			return client_make_command
		end
	end
end

function M.get_client_make_command(client)
	return client_make_command_dict[client]
end

return M
