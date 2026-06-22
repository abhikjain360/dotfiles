return {
  "coder/claudecode.nvim",
  opts = {
    terminal_cmd = "~/.local/bin/claude --dangerously-skip-permissions",
  },
  keys = {},
  -- Keep the IDE integration (launch-from-nvim, selections, diffs) but stop it
  -- from feeding LSP diagnostics to Claude Code. claudecode.nvim hardcodes tool
  -- registration with no per-tool flag, so we neutralize the getDiagnostics tool
  -- before setup() runs (auto_start registers tools during setup):
  --   * schema = nil  -> hidden from the MCP tools/list, so Claude never calls it
  --   * handler stub  -> a direct invocation just returns nothing
  -- pcall-guarded so a future plugin refactor degrades to a no-op, not an error.
  config = function(_, opts)
    pcall(function()
      local diag = require("claudecode.tools.get_diagnostics")
      diag.schema = nil
      diag.handler = function()
        return {}
      end
    end)
    require("claudecode").setup(opts)
  end,
}

