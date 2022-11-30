local nmap = function(keys, func)
	vim.keymap.set('n', keys, func, { noremap = true })
end

local mark = require('harpoon.mark')
local ui = require('harpoon.ui')

nmap('<C-m>', mark.add_file)

for i = 1, 9 do
	nmap(string.format('<leader>%1d', i), function() ui.nav_file(i) end)
end
