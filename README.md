# neovim-dotfiles

My Neovim setup (LazyVim) for macOS, Linux and Windows: one config, cloned onto every machine.

## What's included

```
neovim-dotfiles/
├── README.md
├── Neovim + LazyVim Setup Guide.md   step by step manual setup
├── .gitignore
├── install.sh           macOS, Fedora, CachyOS/Arch
├── install.ps1          Windows
└── nvim/                linked to ~/.config/nvim (or %LOCALAPPDATA%\nvim)
    ├── init.lua
    └── lua/
        ├── config/
        │   ├── lazy.lua       LazyVim + language extras
        │   ├── options.lua
        │   ├── keymaps.lua
        │   └── autocmds.lua
        └── plugins/
            ├── swift.lua      sourcekit-lsp (Xcode's on macOS)
            ├── markdown.lua   markdownlint without the line length rule
            └── treesitter.lua tree-sitter CLI from Mason
```

## Install

### macOS / Linux

```bash
git clone https://github.com/anarchy89/neovim-dotfiles ~/neovim-dotfiles
cd ~/neovim-dotfiles
./install.sh
nvim
```

### Windows (PowerShell)

```powershell
git clone https://github.com/anarchy89/neovim-dotfiles $HOME\neovim-dotfiles
cd $HOME\neovim-dotfiles
powershell -ExecutionPolicy Bypass -File .\install.ps1
nvim
```

The scripts:

1. Install neovim (Homebrew, dnf, pacman or winget), git, ripgrep, fd, node, a C compiler and lazygit, then warn if Neovim is older than 0.11.2 (LazyVim's minimum; Fedora 41 and older are too old)
2. Install FiraCode Nerd Font
3. Move any existing Neovim config and data aside (`*.bak-<timestamp>`)
4. Link `nvim/` into the place Neovim looks for its config

Afterwards, set your terminal's font to **FiraCode Nerd Font** (or **FiraCode Nerd Font Mono** if icons look clipped). On macOS, Ghostty, WezTerm or iTerm2 work better than Terminal.app.

On first launch, wait for plugins and language servers to install (`:Mason` shows progress), restart once, then run `:checkhealth`. Then commit the new `nvim/lazy-lock.json`.

## Languages

| Language | Extra requirement |
| --- | --- |
| Swift | Xcode on macOS (do not use swiftly there); swiftly toolchain on Linux/Windows. Run `swift build` once per project |
| Rust | rustup (`brew install rustup && rustup-init` on macOS) |
| C/C++ | `compile_commands.json` in the project root (CMake: `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`; kernel: `make compile_commands.json`; Makefiles: `bear -- make`) |
| Python | python3 |
| JS/TS | node (installed by the script) |

Add or remove languages in `nvim/lua/config/lazy.lua`.

## Keys

Leader is `Space`.

| Action | Keys |
| --- | --- |
| Open a project | `cd project && nvim .` |
| File tree | `Space e` |
| Bottom terminal | `Ctrl \` (or `Ctrl /` where the terminal app sends it) |
| Leave terminal mode | `Esc Esc` |
| Find file | `Space Space` |
| Search in project | `Space /` |
| Accept completion | `Enter` (`Ctrl Space` opens the menu) |
| Go to definition | `g d` |
| Hover docs | `K` |
| Code action | `Space c a` |
| Rename | `Space c r` |
| Next / prev error | `] d` / `[ d` |
| Diagnostics list | `Space x x` |
| Format | `Space c f` |
| lazygit | `Space g g` |
| Move between splits | `Ctrl h/j/k/l` |
| Save / quit | `:w` / `:q` |

## Updating

```
:Lazy sync          # on one machine, then commit + push nvim/lazy-lock.json
git pull            # on the others
:Lazy restore
```

## Troubleshooting

**Swift builds break after installing something Swift-related on macOS:** check `which -a swift` shows `/usr/bin/swift` first. If not, a toolchain manager such as swiftly has put another Swift first on your PATH. Remove it:

1. `swiftly self-uninstall`, or by hand: delete its line from `~/.zprofile`, `~/.zshrc` and `~/.bash_profile`, then `rm -rf ~/.swiftly ~/.local/share/swiftly`
2. Remove unwanted swift.org toolchains from `~/Library/Developer/Toolchains/` and check `echo $TOOLCHAINS` prints nothing
3. Open a new terminal, confirm `which -a swift`, then in the project: `rm -f .swift-version && rm -rf .build && swift build`

**Icons show as boxes:** the terminal font isn't set to a Nerd Font.

**Format on save is unwanted:** uncomment `vim.g.autoformat = false` in `nvim/lua/config/options.lua`.

**The bottom terminal opening on startup is unwanted:** uncomment `vim.g.auto_terminal = false` in `nvim/lua/config/options.lua`.
