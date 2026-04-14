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

_zsh_syntax_highlighting=""
for _zsh_syntax_highlighting_candidate in \
  "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
do
  if [ -r "$_zsh_syntax_highlighting_candidate" ]; then
    _zsh_syntax_highlighting="$_zsh_syntax_highlighting_candidate"
    break
  fi
done
unset _zsh_syntax_highlighting_candidate

if [ -n "$_zsh_syntax_highlighting" ]; then
  # Load last so the plugin can wrap widgets created by earlier integrations.
  source "$_zsh_syntax_highlighting"

  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

  ZSH_HIGHLIGHT_STYLES[default]='fg=#b3b3b3'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#b07878,bold'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#dad5c8,bold'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#c0c0c0'
  ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#b3ad9f'
  ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#dad5c8,bold'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#c0c0c0,bold'
  ZSH_HIGHLIGHT_STYLES[command]='fg=#c0c0c0,bold'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#8e897d,bold'
  ZSH_HIGHLIGHT_STYLES[autodirectory]='fg=#8e8e8e,bold'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#8e897d'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#8e897d'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#878787'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#878787'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#878787'
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#878787'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#5d5d5d,italic'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#8e8e8e,underline'
  ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#707070'
  ZSH_HIGHLIGHT_STYLES[path_approx]='fg=#a69f91'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=#8e8b85'
  ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#dcb5a5'
  ZSH_HIGHLIGHT_STYLES[arg0]='fg=#c0c0c0,bold'
  ZSH_HIGHLIGHT_STYLES[bracket-error]='fg=#b07878,bold'
  ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#8e897d'
  ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#a69f91'
  ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#dad5c8'
  ZSH_HIGHLIGHT_STYLES[cursor]='standout'
  ZSH_HIGHLIGHT_STYLES[pattern]='fg=#1e1e1e,bg=#8e8b85,bold'
fi

unset _zsh_syntax_highlighting
