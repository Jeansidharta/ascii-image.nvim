---@mod text-image Introduction
---@brief [[
---This is a plugin for displaying an image using only text on a terminal buffer.
---It should be easily extensible and maleable.
---@brief ]]

local config = require("text-image.config")
local utils = require("text-image.utils")

local text_image = {}

---@param win_nr number
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

---
---Opens a new terminal buffer at the window given by win_nr. The terminal
---will execute the configured client (e.g. viu) with the image given at path
---
---NOTE: This buffer may be replaced if the user resizes vim, or the window
---that holds the buffer. Whenever a resize occurs, the buffer will be
---replaced by a new terminal buffer, that will re-run the client command.
---
---The buffer will have a filetype of "text-image"
---
---@param path string The path to the image file
---@param win_nr number
---
---@usage `require("text-image").open_image_at_window("/path/to/image.jpg", 12)`
function text_image.open_image_at_window(path, win_nr)
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
				text_image.open_image_at_window(path, win_nr)
			end)
		end,
		desc = "Redraw image when window or vim is resized",
	})
end

---Find all windows that contain said buffer, and call open_image_at_window on them.
---@param buf_nr number
function text_image.open_image_at_buffer(buf_nr)
	local windows_with_buffer = utils.find_windows_with_buffer(buf_nr)
	local name = vim.api.nvim_buf_get_name(buf_nr)
	vim.schedule(function()
		---@param window number
		vim.tbl_map(function(window)
			if not vim.api.nvim_win_is_valid(window) then
				return
			end
			text_image.open_image_at_window(name, window)
		end, windows_with_buffer)
	end)
end

---@tag :TextImageOpen
---
---Initialize the plugin. Creates a user command TextImageOpen.
---If no arguments provided to this command, will try to render the
---current buffer as an image. If one argument is provided, it is
---treated as a path to the image file that'll be rendered
---
---@param user_config? Config
function text_image.setup(user_config)
	config.init(user_config or {})

	vim.api.nvim_create_user_command(
		"TextImageOpen",
		---@param params { fargs: string[] }
		function(params)
			local name = vim.fs.normalize(params.fargs[1] or vim.api.nvim_buf_get_name(0))
			text_image.open_image_at_window(name, vim.api.nvim_get_current_win())
		end,
		{ force = true, desc = "Preview image in current window", nargs = "?" }
	)

	if config.value.auto_open_on_image then
		vim.filetype.add({
			extension = {
				png = "png",
				jpg = "jpg",
				jpeg = "jpg",
				gif = "gif",
				svg = "svg",
			},
		})

		vim.api.nvim_create_autocmd({ "FileType" }, {
			pattern = { "png", "jpg", "gif", "svg" },
			callback = function(params)
				text_image.open_image_at_buffer(params.buf)
			end,
			desc = "Automatically display image using text-image whenever a image file is opened",
		})
	end
end

return text_image
