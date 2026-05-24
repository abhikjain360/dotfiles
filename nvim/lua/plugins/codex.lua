return {
  "ishiooon/codex.nvim",
  dependencies = { "folke/snacks.nvim" },
  config = true,
  opts = {
    terminal_cmd = "~/.local/bin/codex --yolo",
    keymaps = false,
    status_indicator = {
      enabled = false,
    },
  },
  keys = {
    { "<leader>oo", "<cmd>Codex<cr>", desc = "Codex: Toggle", mode = { "n", "t" } },
    { "<leader>of", "<cmd>CodexFocus<cr>", desc = "Codex: Focus" },
    { "<leader>os", "<cmd>CodexSend<cr>", desc = "Codex: Send selection", mode = "v" },
    { "<leader>ob", "<cmd>CodexAdd %<cr>", desc = "Codex: Add buffer" },
    {
      "<leader>ot",
      "<cmd>CodexTreeAdd<cr>",
      desc = "Codex: Add tree file",
      ft = { "neo-tree", "neo-tree-popup", "oil" },
    },
    { "<leader>oa", "<cmd>CodexDiffAccept<cr>", desc = "Codex: Accept diff" },
    { "<leader>od", "<cmd>CodexDiffDeny<cr>", desc = "Codex: Deny diff" },
  },
}
