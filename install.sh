#!/usr/bin/env bash
# Install Neovim + LazyVim config from this repo on macOS, Fedora or CachyOS/Arch.
# Safe to re-run: existing installs are skipped and an existing link is left alone.
# tree-sitter CLI is not installed here: Mason installs it on first launch (nvim/lua/plugins/treesitter.lua).
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
NVIM_TARGET="$CONFIG_HOME/nvim"
STAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*"; }

detect_os() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo macos
    return
  fi
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case " ${ID:-} ${ID_LIKE:-} " in
      *" fedora "*) echo fedora; return ;;
      *" arch "*|*" cachyos "*) echo arch; return ;;
    esac
  fi
  echo unknown
}

install_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required: https://brew.sh" >&2
    exit 1
  fi
  info "Installing packages (Homebrew)"
  brew install neovim git ripgrep fd node lazygit
  if compgen -G "$HOME/Library/Fonts/FiraCodeNerdFont*" >/dev/null \
    || compgen -G "/Library/Fonts/FiraCodeNerdFont*" >/dev/null; then
    info "FiraCode Nerd Font already installed"
  else
    info "Installing FiraCode Nerd Font"
    brew install --cask font-fira-code-nerd-font || warn "font install failed; install it by hand"
  fi

  # Swift must come from Xcode on macOS (see README troubleshooting)
  if command -v swift >/dev/null 2>&1; then
    first_swift="$(command -v swift)"
    if [[ "$first_swift" != "/usr/bin/swift" ]]; then
      warn "swift on PATH is $first_swift, not Xcode's /usr/bin/swift. Remove swiftly (see README troubleshooting)."
    fi
  fi
  if ! xcode-select -p 2>/dev/null | grep -q "Xcode.app"; then
    warn "xcode-select does not point at Xcode.app. Run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  fi
}

install_fedora() {
  info "Installing packages (dnf)"
  sudo dnf install -y neovim git ripgrep fd-find nodejs npm gcc make curl tar xz unzip
  # lazygit is in Fedora's own repos from Fedora 43; optional, so older releases just skip it
  if ! command -v lazygit >/dev/null 2>&1; then
    info "Installing lazygit (dnf)"
    sudo dnf install -y lazygit \
      || warn "lazygit is not in this Fedora release's repos (needs Fedora 43+); it is optional"
  fi

  local font_dir="$DATA_HOME/fonts/FiraCode"
  if [[ ! -d "$font_dir" ]]; then
    info "Installing FiraCode Nerd Font to $font_dir"
    mkdir -p "$font_dir"
    curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.tar.xz \
      | tar -xJ -C "$font_dir"
    fc-cache -f "$font_dir"
  fi
}

install_arch() {
  info "Installing packages (pacman)"
  sudo pacman -S --needed --noconfirm \
    neovim git ripgrep fd nodejs npm gcc make lazygit ttf-firacode-nerd
}

check_nvim_version() {
  # LazyVim needs Neovim >= 0.11.2 (Fedora 41 and older ship 0.10.x)
  if ! command -v nvim >/dev/null 2>&1; then
    warn "nvim not found on PATH"
    return
  fi
  local v major minor patch
  v="$(nvim --version | head -n 1 | sed -E 's/^NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/')"
  if [[ ! "$v" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    warn "could not read the Neovim version; LazyVim needs 0.11.2 or newer"
    return
  fi
  IFS=. read -r major minor patch <<<"$v"
  if (( major == 0 && (minor < 11 || (minor == 11 && patch < 2)) )); then
    warn "Neovim $v is too old for LazyVim (needs 0.11.2+). Upgrade the OS or install a newer Neovim."
  else
    info "Neovim $v"
  fi
}

backup_existing() {
  # Already linked to this repo: nothing to do
  if [[ -L "$NVIM_TARGET" && "$(readlink "$NVIM_TARGET")" == "$REPO_DIR/nvim" ]]; then
    info "$NVIM_TARGET already links to this repo"
    return 1
  fi
  local p
  for p in "$NVIM_TARGET" "$DATA_HOME/nvim" "$STATE_HOME/nvim" "$CACHE_HOME/nvim"; do
    if [[ -e "$p" || -L "$p" ]]; then
      info "Backing up $p -> $p.bak-$STAMP"
      mv "$p" "$p.bak-$STAMP"
    fi
  done
  return 0
}

link_config() {
  mkdir -p "$CONFIG_HOME"
  ln -s "$REPO_DIR/nvim" "$NVIM_TARGET"
  info "Linked $NVIM_TARGET -> $REPO_DIR/nvim"
}

main() {
  local os
  os="$(detect_os)"
  info "Detected: $os"
  case "$os" in
    macos) install_macos ;;
    fedora) install_fedora ;;
    arch) install_arch ;;
    *)
      warn "Unsupported OS; skipping package install. Install neovim, git, ripgrep, fd, node, a C compiler and a Nerd Font yourself."
      ;;
  esac
  check_nvim_version

  if backup_existing; then
    link_config
  fi

  echo
  info "Done. Next:"
  echo "  1. Set your terminal font to 'FiraCode Nerd Font'"
  echo "  2. Run nvim, wait for plugins and :Mason to finish, restart, then :checkhealth"
  echo "  3. Commit nvim/lazy-lock.json"
}

main "$@"
