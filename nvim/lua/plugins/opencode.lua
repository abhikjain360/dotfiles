return {
  "nickjvandyke/opencode.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {},
  init = function()
    vim.o.autoread = true
  end,
  keys = {
    { "<leader>oo", function() require("opencode").toggle() end, desc = "Toggle opencode", mode = { "n", "t" } },
    { "<leader>oa", function() require("opencode").ask("@this: ", { submit = true }) end, desc = "Ask opencode", mode = { "n", "x" } },
    { "<leader>ox", function() require("opencode").select() end, desc = "Select opencode action", mode = { "n", "x" } },
  },
}
