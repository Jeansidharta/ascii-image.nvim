local config = require("text-image.config")

local M = {}

local function make_window_style_minimal(win_nr)
	vim.api.nvim_win_call(win_nr, function()
		vim.wo.number = false
		vim.wo.relativenumber = false
		vim.wo.cursorline = false
		vim.wo.cursorcolumn = false
		vim.wo.foldcolumn = "auto"
		vim.wo.spell = false
		vim.wo.list = false
		vim.wo.signcolumn = "auto"
		vim.wo.colorcolumn = ""
		vim.wo.signcolumn = "no"
	end)
end

--- @param path string
--- @param win_nr number
function preview_image_at_window(path, win_nr)
	make_window_style_minimal(win_nr)

	local width = vim.api.nvim_win_get_width(win_nr)
	local height = vim.api.nvim_win_get_height(win_nr)
	local buffer = vim.fn.bufadd("term://" .. config.client(path, width, height))

	vim.api.nvim_buf_set_option(buffer, "filetype", "text-image")
	vim.api.nvim_win_set_buf(win_nr, buffer)

	vim.api.nvim_create_autocmd({ "ModeChanged" }, {
		buffer = buffer,
		callback = function()
			local new_mode = vim.v.event.new_mode
			if new_mode == "t" then
				vim.cmd([[:stopinsert]])
			end
		end,
		desc = "Prevent user from going into terminal mode",
	})

	vim.api.nvim_create_autocmd({ "VimResized", "WinScrolled" }, {
		buffer = buffer,
		callback = function()
			vim.schedule(function()
				if not vim.api.nvim_win_is_valid(win_nr) then
					return
				end
				preview_image_at_window(path, win_nr)
			end)
		end,
		desc = "Redraw image when window or vim is resized",
	})
end

function M.setup(user_config)
	config.init(user_config or {})

	vim.api.nvim_create_user_command("TextImageOpen", function(params)
		local name = vim.fs.normalize(params.fargs[1] or vim.api.nvim_buf_get_name(0))
		preview_image_at_window(name, vim.api.nvim_get_current_win())
	end, { force = true, desc = "Preview image" })
end

return M
