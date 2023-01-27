local config = require("text-image.config")
local filename_scheme = require("text-image.filename-scheme")

local M = {}

local function make_window_style_minimal()
	vim.wo.number = false
	vim.wo.relativenumber = false
	vim.wo.cursorline = false
	vim.wo.cursorcolumn = false
	vim.wo.foldcolumn = "auto"
	vim.wo.spell = false
	vim.wo.list = false
	vim.wo.signcolumn = "auto"
	vim.wo.colorcolumn = ""
end

function preview_image(buffer, path, make_client_command)
	make_window_style_minimal()

	local terminal = vim.api.nvim_open_term(buffer, {})

	local width = vim.api.nvim_win_get_width(0)
	local height = vim.api.nvim_win_get_height(0)

	vim.fn.jobstart(make_client_command(path, width, height), {
		on_stdout = function(_, data)
			local NEWLINE = "\x0A"
			local CURSOR_BACK = "\x1B[9999D"
			vim.tbl_map(function(line)
				vim.api.nvim_chan_send(terminal, line .. NEWLINE .. CURSOR_BACK)
			end, data)
		end,
	})

	vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
		buffer = buffer,
		callback = function()
			vim.schedule(function()
				if vim.api.nvim_buf_is_valid(buffer) then
					vim.api.nvim_buf_delete(buffer, { force = true })
				end
			end)
		end,
		desc = "Kill buffer",
	})
	-- vim.api.nvim_win_set_cursor(0, { 0, -1 })
end

function M.setup(user_config)
	config.init(user_config or {})

	vim.api.nvim_create_user_command("TextImageOpen", function()
		local name = vim.api.nvim_buf_get_name(0)
		local scheme = filename_scheme.path_to_scheme(name)
		local new_buf = vim.fn.bufadd(scheme)
		vim.api.nvim_win_set_buf(0, new_buf)
	end, { force = true, desc = "Preview image" })

	local autocmd_pattern = filename_scheme.scheme_pattern .. "*"
	vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
		callback = function(params)
			local name = vim.api.nvim_buf_get_name(params.buf)
			local path = filename_scheme.scheme_to_path(name)
			preview_image(params.buf, path, config.client)
		end,
		pattern = autocmd_pattern,
		desc = "Read text-image",
	})

	vim.api.nvim_create_autocmd({ "BufWriteCmd" }, { pattern = autocmd_pattern, callback = function() end })
end

return M
