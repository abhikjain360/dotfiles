local telescope = require('telescope')
local builtin = require('telescope.builtin')

-- utility
local nmap = function(keys, func)
	vim.keymap.set('n', keys, func, { noremap = true })
end

-- file pickers
nmap('<space>ff', builtin.find_files)
nmap('<space>fs', builtin.live_grep)

-- vim pickers
nmap('<space>fb', builtin.buffers)

-- git pickers
nmap('<space>fgs', builtin.git_status)
nmap('<space>fgh', builtin.git_stash)

-- extensions
--
	-- faster fzf
	telescope.load_extension('fzf')

	-- harpooning
	telescope.load_extension('harpoon')
	nmap('<space>fh', '<cmd>Telescope harpoon marks<cr>')
