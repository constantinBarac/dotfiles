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
  golang
  fzf-zsh-plugin
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# -- Theme & Aliases --
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -f "$DOTFILES/zsh/aliases.zsh" ] && source "$DOTFILES/zsh/aliases.zsh"

# -- Tool Initialization (cached) --
# Cache eval output; invalidates when the tool binary is updated
_eval_cache() {
  local name="$1"; shift
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/${name}.zsh"
  local tool="${commands[$1]:-$(command -v $1 2>/dev/null)}"
  if [[ ! -f "$cache" || ( -n "$tool" && "$tool" -nt "$cache" ) ]]; then
    mkdir -p "${cache:h}"
    "$@" > "$cache" 2>/dev/null
  fi
  source "$cache"
}

_eval_cache direnv direnv hook zsh
_eval_cache nodenv  nodenv init - --no-rehash zsh
_eval_cache zoxide  zoxide init zsh
_eval_cache pyenv   pyenv init - --no-rehash zsh

# -- Lazy Completions --
kubectl() {
  unfunction "$0"
  source <(command kubectl completion zsh)
  command kubectl "$@"
}

# Google Cloud SDK path
if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then
  . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'
fi

# Load existing user-specific configs not tracked in git
[ -f ~/.airc ] && source ~/.airc

# bun completions
[ -s "/Users/ibar/.bun/_bun" ] && source "/Users/ibar/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
