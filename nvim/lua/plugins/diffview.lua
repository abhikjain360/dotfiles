---Yank the repo-relative `path:line` of the current file.
---Works in normal buffers and in every diffview pane (including the
---diffview:// revision pane, resolved through the view's FileEntry).
local function yank_path_line()
  local line = vim.fn.line(".")
  local lib = package.loaded["diffview.lib"] and require("diffview.lib") or nil
  local view = lib and lib.get_current_view()

  if view then
    -- inside a diffview tab: resolve the file through the view
    local file = view.infer_cur_file and view:infer_cur_file()
    if not file and view.panel and view.panel.cur_item then
      file = view.panel.cur_item[2] -- file-history view: { LogEntry, FileEntry }
    end
    if file and file.absolute_path then -- FileEntry, not a directory row
      local ref = file.path
      if not (view.panel and view.panel.is_focused and view.panel:is_focused()) then
        ref = ref .. ":" .. line
      end
      vim.fn.setreg("+", ref)
      vim.notify("yanked: " .. ref)
    else
      vim.notify("no file under cursor", vim.log.levels.WARN)
    end
    return
  end

  if vim.bo.buftype ~= "" or vim.fn.expand("%"):match("^diffview://") then
    vim.notify("not a real file pane — use the working-tree (right) pane or `gf` first", vim.log.levels.WARN)
    return
  end
  local ref = vim.fn.expand("%:.") .. ":" .. line
  vim.fn.setreg("+", ref)
  vim.notify("yanked: " .. ref)
end

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },

  -- global "yank path:line" for normal buffers. Diff panes need a
  -- buffer-local copy (keymaps.view below): diffview sets buffer-local
  -- <leader> maps in its diff buffers, which makes which-key install a
  -- buffer-local nowait trigger on <Space> there — a global <leader>yl
  -- then never reaches nvim's mapping resolution and degrades to plain yl.
  init = function()
    vim.keymap.set("n", "<leader>yl", yank_path_line, { desc = "Yank path:line" })
  end,

  -- lazy.nvim calls require("diffview").setup(opts) for you on load
  opts = {
    keymaps = {
      -- buffer-local <leader>yl in every diff pane
      view = {
        { "n", "<leader>yl", yank_path_line, { desc = "Yank path:line" } },
      },
      -- yank file path from the file panel
      file_panel = {
        {
          "n",
          "y",
          function()
            local view = require("diffview.lib").get_current_view()
            local panel = view and view.panel
            local item = panel and panel.get_item_at_cursor and panel:get_item_at_cursor()
            if item and item.absolute_path then -- FileEntry, not a directory row
              vim.fn.setreg("+", item.path) -- item.absolute_path for the full path
              vim.notify("yanked: " .. item.path)
            else
              vim.notify("no file under cursor", vim.log.levels.WARN)
            end
          end,
          { desc = "Yank file path" },
        },
      },
    },
  },
}
