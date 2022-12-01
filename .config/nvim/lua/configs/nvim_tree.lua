local nmap = function(k, c)
	vim.keymap.set('n', k, c, { noremap = true, silent = true })

end

nmap('<space>f', '<cmd>NvimTreeToggle<cr>')

require("nvim-tree").setup {
	disable_netrw = true,
	hijack_cursor = true,
	sort_by = "name",
	on_attach = "disable", -- TODO: use this when view.mappings gets deprecated
	view = {
		width = 40,
		number = true,
		relativenumber = true,
		signcolumn = "yes",
		mappings = {
			custom_only = false,
			list = {
				{ key = { '<CR>', 'l' }, action = 'edit', mode = 'n' }
			},
		},
	},
	diagnostics = {
		enable = true,
		show_on_dirs = true,
		show_on_open_dirs = true,
		debounce_delay = 50,
		severity = {
			min = vim.diagnostic.severity.HINT,
			max = vim.diagnostic.severity.ERROR
		},
		icons = {
			hint = "",
			info = "",
			warning = "",
			error = "",
		},
	},
	tab = {
		sync = {
			open = true,
		},
	},
}
