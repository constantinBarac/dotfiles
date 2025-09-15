typeset  -aU path

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  "git"
  "git-extras"
  "gnu-utils"
  "docker"
  "docker-compose"
  "kubectl"
  "golang"
  "fzf-zsh-plugin"
)

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="$GOPATH/bin:$PATH"
export GOPATH="$HOME/go"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


if [ -f '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc' ]; then . '/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc'; fi

eval "$(direnv hook zsh)"
eval "$(nodenv init - --no-rehash bash)"
eval "$(zoxide init zsh)"

source ~/.airc
