local telescope = require('telescope')
local builtin = require('telescope.builtin')

-- utility
local nmap = function(keys, func)
	vim.keymap.set('n', keys, func, { noremap = true })
end

-- file pickers
nmap('<space>tf', builtin.find_files)
nmap('<space>ts', builtin.live_grep)
nmap('<space>tb', builtin.buffers)

-- lsp pickers
nmap('<space>lr', builtin.lsp_references)
nmap('<space>ls', builtin.lsp_document_symbols)
nmap('<space>lS', builtin.lsp_workspace_symbols)
nmap('<space>ld', function() builtin.diagnostics { bufnr = 0 } end)
nmap('<space>lD', builtin.diagnostics)

-- git pickers
nmap('<space>fgs', builtin.git_status)
nmap('<space>fgh', builtin.git_stash)

-- extensions
--
-- faster fzf
telescope.load_extension('fzf')


local trouble = require("trouble.providers.telescope")

telescope.setup {
  defaults = {
    mappings = {
      i = { ["<c-t>"] = trouble.open_with_trouble },
      n = { ["<c-t>"] = trouble.open_with_trouble },
    },
  },
}
