# Neovim + LazyVim Setup Guide

Nov 25, 2026 · @unknown

> Note: this is the manual route, written before the install scripts existed. In this repo, run `install.sh` or `install.ps1` instead; see README.md.

## Overview

This guide sets up Neovim with LazyVim on macOS, then on Fedora, CachyOS and Windows from the same git repo. You get a file tree, a bottom terminal, LSP completion and diagnostics for Swift, Rust, C/C++, Python and JS/TS, and FiraCode Nerd Font for icons.

Order on a fresh Mac: check Xcode Swift, install tools and the font, install LazyVim, enable languages, add Swift, then push the config to git. Every later machine is install tools, install font, clone, open nvim.

## macOS setup

### 1. Confirm you are on Xcode's Swift

```bash
which -a swift        # /usr/bin/swift should be first
xcode-select -p       # /Applications/Xcode.app/Contents/Developer
```

If `xcode-select -p` shows something else:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

If swiftly is still on your PATH, clear it first (see Troubleshooting at the end).

### 2. Install the tools

```bash
brew install neovim git ripgrep fd node lazygit
```

### 3. Install FiraCode Nerd Font

```bash
brew install --cask font-fira-code-nerd-font
```

Then set your terminal's font to **FiraCode Nerd Font** (if icons look clipped or overlap, use **FiraCode Nerd Font Mono** instead):

- **Terminal.app:** Settings > Profiles > Text > Font > Change
- **iTerm2:** Settings > Profiles > Text > Font
- **Ghostty:** add `font-family = "FiraCode Nerd Font"` to `~/.config/ghostty/config`
- **WezTerm:** `config.font = wezterm.font("FiraCode Nerd Font")` in `~/.wezterm.lua`

Terminal.app works, but Ghostty, WezTerm or iTerm2 give better colours and key handling.

### 4. Back up any old Neovim config

Skip this if you have never used Neovim on this Mac.

```bash
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

### 5. Install LazyVim

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim
```

The first launch downloads all plugins. Wait for it to finish, quit with `:q` and reopen. Run `:checkhealth` once and fix anything marked as an error; warnings for languages you don't use are fine.

### 6. Turn on your languages

Run `:LazyExtras`, move the cursor to each of these and press `x`:

- `lang.rust`
- `lang.clangd` (C and C++)
- `lang.python`
- `lang.typescript` (JavaScript and TypeScript)
- `lang.json`, `lang.markdown`, `lang.toml`, `lang.yaml`

Restart Neovim. Mason installs the language servers in the background; `:Mason` shows progress.

### 7. Add Swift

Create `~/.config/nvim/lua/plugins/swift.lua`:

```lua
local is_mac = vim.fn.has("mac") == 1
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      sourcekit = {
        mason = false,
        cmd = is_mac and { "xcrun", "sourcekit-lsp" } or { "sourcekit-lsp" },
      },
    },
  },
}
```

On macOS this always uses Xcode's sourcekit-lsp, whatever is on your PATH. Run `swift build` once in each Swift project so completion has an index to work from.

### 8. Optional: turn off format on save

Add to `~/.config/nvim/lua/config/options.lua`:

```lua
vim.g.autoformat = false
```

Format by hand with `Space c f`.

## Per-language requirements

| Language | What you need | Notes |
| --- | --- | --- |
| Swift | Xcode (macOS) or the Swift toolchain via swiftly (Linux, Windows) | Run `swift build` once per project |
| Rust | rustup (`brew install rustup && rustup-init`) | rust-analyzer comes from Mason |
| C/C++ | `compile_commands.json` in the project root | CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`; kernel: `make compile_commands.json`; plain Makefiles: `brew install bear` then `bear -- make` |
| Python | python3 | Activate a venv before opening nvim |
| JS/TS | node | Installed in the tools step |

## Daily use

Leader is `Space`; press it and wait to see every option.

| Action | Keys |
| --- | --- |
| Open a project | `cd project && nvim .` |
| File tree | `Space e` |
| Terminal at the bottom (toggle) | `Ctrl /` |
| Leave terminal typing mode | `Esc Esc` |
| Find file | `Space Space` |
| Search text in project | `Space /` |
| Accept completion | `Enter` (`Ctrl Space` opens the menu) |
| Go to definition | `g d` |
| Show docs | `K` |
| Code actions / quick fix | `Space c a` |
| Rename symbol | `Space c r` |
| Next / previous error | `] d` / `[ d` |
| All diagnostics | `Space x x` |
| Format file | `Space c f` |
| Git (lazygit) | `Space g g` |
| Move between splits | `Ctrl h/j/k/l` |
| Save / quit | `:w` / `:q` |

## Sync with git

Push the config once from your Mac; every other machine clones it.

```bash
cd ~/.config/nvim
git init
git add .
git commit -m "my LazyVim config"
git remote add origin https://github.com/<you>/nvim-config.git
git push -u origin main
```

Keep `lazy-lock.json` committed: it pins every plugin to the same version on every machine. A public repo means new machines can clone without logging in.

**Updating:**

1. On one machine, run `:Lazy sync`, then commit and push `lazy-lock.json`.
2. On the others, run `git pull`, then `:Lazy restore` inside Neovim.

## New machine

Each machine is three steps: install tools, install FiraCode Nerd Font, clone the config and open nvim. Set the terminal font to **FiraCode Nerd Font** afterwards.

### Fedora

```bash
sudo dnf install neovim git ripgrep fd-find nodejs gcc make
sudo dnf install lazygit   # optional; in Fedora's own repos from Fedora 43

# FiraCode Nerd Font
mkdir -p ~/.local/share/fonts/FiraCode
curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz \
  | tar -xJ -C ~/.local/share/fonts/FiraCode
fc-cache -f

git clone https://github.com/<you>/nvim-config ~/.config/nvim && nvim
```

### CachyOS

```bash
sudo pacman -S neovim git ripgrep fd nodejs gcc make lazygit ttf-firacode-nerd
git clone https://github.com/<you>/nvim-config ~/.config/nvim && nvim
```

On Linux, install Swift with swiftly. That is the normal route there and does not clash with anything.

### Windows (PowerShell)

```powershell
winget install Neovim.Neovim Git.Git BurntSushi.ripgrep.MSVC sharkdp.fd OpenJS.NodeJS zig.zig JesseDuffield.lazygit

# FiraCode Nerd Font via Scoop
scoop bucket add nerd-fonts
scoop install FiraCode-NF

git clone https://github.com/<you>/nvim-config $env:LOCALAPPDATA\nvim
nvim
```

No Scoop? Download `FiraCode.zip` from the [Nerd Fonts releases page](https://github.com/ryanoasis/nerd-fonts/releases/latest), extract it, select the `.ttf` files, right-click and choose **Install for all users**. Then in Windows Terminal: Settings > Profiles > Defaults > Appearance > Font face > FiraCode Nerd Font.

zig provides the C compiler the syntax parsers need on Windows.

## Troubleshooting: swiftly on macOS

On a Mac, swiftly puts a swift.org toolchain ahead of Xcode's on your PATH, which breaks Xcode-built projects. Remove it and rebuild.

1. Uninstall swiftly with `swiftly self-uninstall`. If that command doesn't exist:
   - delete the swiftly line from `~/.zprofile`, `~/.zshrc` and `~/.bash_profile`
   - `rm -rf ~/.swiftly ~/.local/share/swiftly`
   - remove unwanted swift.org toolchains from `~/Library/Developer/Toolchains/`
   - check `echo $TOOLCHAINS` prints nothing
2. Open a new terminal and confirm `which -a swift` shows `/usr/bin/swift` first.
3. Clean the project:

```bash
cd your-project
rm -f .swift-version
rm -rf .build
swift build
```

Add `.build/`, `.swiftpm/` and `.vscode/` to `.gitignore` so generated files never show up as changes.

## Sources

- [Nerd Fonts: FiraCode](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode)
- [LazyVim starter](https://github.com/LazyVim/starter)
- [SourceKit-LSP](https://github.com/swiftlang/sourcekit-lsp)
