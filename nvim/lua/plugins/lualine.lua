return {
  -- Show the full file path in the statusline instead of LazyVim's default,
  -- which collapses anything deeper than 3 segments into "dir/…/file".
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Find LazyVim's pretty_path component and swap it for a non-truncating
      -- one, in place. It is the only lualine_c entry that is a bare
      -- { <function> } with no `cond`/`color` (root_dir and the symbols
      -- breadcrumb both carry a `cond`), so match on that rather than a
      -- brittle index — other components shift the position around.
      -- length = 0 -> never truncate (full path). Use a number (e.g. 8) for a
      -- generous-but-capped limit instead.
      for _, comp in ipairs(opts.sections.lualine_c) do
        if type(comp) == "table" and type(comp[1]) == "function" and comp.cond == nil and comp.color == nil then
          comp[1] = LazyVim.lualine.pretty_path({ length = 0 })
        end
      end
    end,
  },
}
