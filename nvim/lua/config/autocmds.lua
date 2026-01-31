-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local set_tabsize = function()
  vim.opt.tabstop = 4 -- Number of visual spaces per TAB
  vim.opt.softtabstop = 4 -- Number of spaces for a tab press
  vim.opt.shiftwidth = 4 -- Number of spaces for indentation
  vim.opt.expandtab = true -- Convert tabs to spaces
end

-- Apply this setting for the specific file types
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "typescript", "typescriptreact", "javascript", "javascriptreact", "json" },
  callback = set_tabsize,
})
