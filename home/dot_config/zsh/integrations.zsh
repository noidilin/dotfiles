setopt auto_cd interactive_comments
bindkey -v

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v carapace >/dev/null 2>&1; then
  source <(carapace _carapace zsh)
fi

if command -v chezmoi >/dev/null 2>&1; then
  eval "$(chezmoi completion zsh)"
fi
