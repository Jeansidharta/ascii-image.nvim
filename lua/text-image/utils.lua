local utils = {}

---Find all windows that contain buf_nr
---@param buf_nr number
function utils.find_windows_with_buffer(buf_nr)
	local windows = vim.api.nvim_list_wins()
	return vim.tbl_filter(function(window)
		return vim.api.nvim_win_get_buf(window) == buf_nr
	end, windows)
end

return utils
