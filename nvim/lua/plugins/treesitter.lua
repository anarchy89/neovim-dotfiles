-- tree-sitter CLI (needed by nvim-treesitter to build parsers) comes from Mason on every OS:
-- a pinned, prebuilt binary from tree-sitter's own GitHub releases, no npm or sudo.
-- Skipped if a tree-sitter is already on PATH (for example from Homebrew or pacman).
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      if vim.fn.executable("tree-sitter") == 0 then
        opts.ensure_installed = opts.ensure_installed or {}
        table.insert(opts.ensure_installed, "tree-sitter-cli")
      end
    end,
  },
}
