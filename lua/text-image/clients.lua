local M = {}

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
