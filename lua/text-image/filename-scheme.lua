local M = {}

M.scheme_pattern = "text-image://"

function M.path_to_scheme(path)
	return M.scheme_pattern .. path
end

function M.scheme_to_path(scheme)
	if not vim.startswith(scheme, M.scheme_pattern) then
		error("Scheme not recognised. Must start with " .. M.scheme_pattern, 2)
	end

	return string.sub(scheme, string.len(M.scheme_pattern) + 1)
end

return M
