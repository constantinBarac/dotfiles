#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "🚀 Starting Dotfiles Installation..."

# 1. Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "🍺 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. Bundle Dependencies
echo "📦 Installing Bundle..."
brew bundle --file="$DOTFILES/Brewfile"

# 3. Backup & Symlink
mkdir -p "$BACKUP_DIR"

link_file() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Example: Backing up $dest to $BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    fi
    
    mkdir -p "$(dirname "$dest")"
    ln -sf "$src" "$dest"
}

echo "🔗 Linking Configs..."
link_file "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
link_file "$DOTFILES/tmux/config/tmux.conf" "$HOME/.tmux.conf"
link_file "$DOTFILES/nvim" "$HOME/.config/nvim"

# 4. Post-Install Setup
echo "🔌 Setting up plugins..."

# Install TPM if missing
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "  -> Installing Tmux Plugin Manager..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install Zsh plugins if missing
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "  -> Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "  -> Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting
fi

echo "✅ Done! Reload your shell."
