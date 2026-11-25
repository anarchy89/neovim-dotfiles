-- Swift via sourcekit-lsp (ships with Xcode / the Swift toolchain, not Mason).
-- On macOS, always use Xcode's copy through xcrun, whatever is on PATH.
local is_mac = vim.fn.has("mac") == 1

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          mason = false,
          cmd = is_mac and { "xcrun", "sourcekit-lsp" } or { "sourcekit-lsp" },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "swift" } },
  },
}
