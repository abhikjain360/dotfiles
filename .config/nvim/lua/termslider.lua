local termname = 'zsh'

local toggleTermnial = function(slider)
	local pane = vim.fn.bufwinnr(termname)
	local buf_exists = vim.fn.bufexists(termname)
	print(pane)
	if pane > 0 then
		vim.cmd(string.format(':exe %d . "wincmd w" | wincmd c', pane))
		print(pane)
	elseif buf_exists > 0 then
		if slider then
			vim.cmd(string.format([[
			vs
			buffer %s
			]], termname))
		else
			vim.cmd(string.format([[
			sp
			buffer %s
			]], termname))
		end

	else
		if slider then
			vim.cmd([[
				vs
				terminal
				f zsh
			]])
		else
			vim.cmd([[
				sp
				terminal
				f zsh
			]])
		end
	end
end

vim.keymap.set('n', '<space>\'', function() toggleTermnial(true) end, { noremap = true })
vim.keymap.set('n', '<space>"', function() toggleTermnial(false) end, { noremap = true })
