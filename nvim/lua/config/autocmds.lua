-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Uncomment to stop format on save for Swift files only
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "swift",
--   callback = function()
--     vim.b.autoformat = false
--   end,
-- })

-- Always open the bottom terminal on startup, keeping the cursor in the editor.
-- Same terminal that Ctrl+/ and Ctrl+\ toggle. Skipped when nvim runs without a UI
-- (headless) or as git's editor for a commit or rebase message.
-- To turn it off, set vim.g.auto_terminal = false in options.lua.
vim.schedule(function()
  if vim.g.auto_terminal == false or #vim.api.nvim_list_uis() == 0 then
    return
  end
  if vim.tbl_contains({ "gitcommit", "gitrebase" }, vim.bo.filetype) then
    return
  end
  local win = vim.api.nvim_get_current_win()
  Snacks.terminal.get(nil, { cwd = LazyVim.root(), start_insert = false })
  if vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_set_current_win(win)
  end
  vim.cmd.stopinsert()
end)
