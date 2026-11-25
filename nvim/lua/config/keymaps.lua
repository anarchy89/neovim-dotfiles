-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add your own keymaps here

-- Terminal toggle on Ctrl+\ as well as LazyVim's Ctrl+/ (some terminals, like iTerm2 and
-- Terminal.app by default, never send Ctrl+/). In terminal mode this replaces the Ctrl+\ prefix
-- of Ctrl+\ Ctrl+n; use Esc Esc to leave terminal mode instead.
vim.keymap.set({ "n", "t" }, "<C-\\>", function()
  Snacks.terminal.focus(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })
