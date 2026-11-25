-- File explorer (Space e): always show dotfiles (.gitignore) and git-ignored files.
-- H and I in the explorer still toggle them off for the session.
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = { hidden = true, ignored = true },
        },
      },
    },
  },
}
