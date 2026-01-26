# Path to your dotfiles repo
export DOTFILES="$HOME/dotfiles"

# Enable Powerlevel10k instant prompt. Should stay close to the top.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -- Path Setup --
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

# -- Zsh Plugins (Oh My Zsh) --
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
  git
  git-extras
  docker
  docker-compose
  kubectl
  golang
  fzf-zsh-plugin
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# -- Theme & Aliases --
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f "$DOTFILES/zsh/aliases.zsh" ] && source "$DOTFILES/zsh/aliases.zsh"

# -- Tool Initialization --
eval "$(direnv hook zsh)"
eval "$(nodenv init - --no-rehash zsh)"
eval "$(zoxide init zsh)"
eval "$(pyenv init - zsh)"

# Google Cloud SDK (if present)
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

# Load existing user-specific configs not tracked in git
[ -f ~/.airc ] && source ~/.airc
