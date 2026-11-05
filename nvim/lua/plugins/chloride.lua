local dir = vim.fn.expand("~/coding/llms/chloride/editor/nvim")

return {
  {
    dir = dir,
    name = "chloride",
    lazy = false,
    enabled = vim.fn.isdirectory(dir) == 1,
  },
}
