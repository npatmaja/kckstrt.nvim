local M = {}

M.config = {}

-- this module to automatically install LSPs using mason v2
function M.setup(config)
	if config then
		-- check the ensure installed is there
		if not config.ensure_installed then
			return
		end
		M.config.ensure_installed = vim.tbl_deep_extend('force', {}, config.ensure_installed or {})
	end
end

function M.install_lsps()
	vim.notify('Starting to install LSPs', vim.log.levels.INFO)
	local mregistry = require('mason-registry')

	for key, value in pairs(M.config.ensure_installed or {}) do
		local server = ''
		if type(key) == 'string' then
			server = key
		elseif type(value) == 'string' then
			server = value
		end
		vim.notify('Installing ' .. key, vim.log.levels.INFO)

		if mregistry.has_package(server) then
			local pkg = mregistry.get_package(server)
			pkg:install({}, function(success, error)
				if not success then
					vim.notify('Error installing ' .. server .. ' . Error: ' .. error, vim.log.levels.ERROR)
				end
			end)
		else
			vim.notify('Can not found ' .. server .. ' in the Mason registry. Continuing to the next LSP', vim.log.levels.WARN)
		end
	end
end

return M
