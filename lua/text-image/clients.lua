---@mod text-image.clients

local clients = {}

---@alias ClientMakeCommand fun(path: string, width: number, height: number): string

---@private
---@type table<string, ClientMakeCommand>
local client_make_command_dict = {
	["chafa"] = function(path, width, height)
		return "chafa " .. path .. " --size=" .. width .. "x" .. height
	end,
	["viu"] = function(path)
		return "viu --transparent " .. path
	end,
	["termpix"] = function(path, width, height)
		return "termpix --true-color " .. path .. " --max-width " .. width .. " --max-height " .. height
	end,
	["tiv"] = function(path)
		return "tiv " .. path
	end,
}

---@private
---@return ClientMakeCommand | nil
function clients.detect_client()
	local has_client = vim.fn.executable

	for client_name, client_make_command in pairs(client_make_command_dict) do
		if has_client(client_name) then
			return client_make_command
		end
	end
end

---@private
---@param client string
---@return nil | ClientMakeCommand
function clients.get_client_make_command(client)
	return client_make_command_dict[client]
end

return clients
