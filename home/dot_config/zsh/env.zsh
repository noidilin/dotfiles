export EZA_CONFIG_DIR="${HOME}/.config/eza"
export BAT_CONFIG_DIR="${HOME}/.config/bat"
export YAZI_CONFIG_HOME="${HOME}/.config/yazi"

export EDITOR="nvim"
export PAGER="delta"
export CARAPACE_BRIDGES="zsh,fish,bash,inshellisense"
export CC="gcc"

if command -v vivid >/dev/null 2>&1; then
  _vivid_theme="${XDG_CONFIG_HOME:-$HOME/.config}/vivid/themes/achroma.yml"
  if [ -f "$_vivid_theme" ]; then
    export LS_COLORS="$(vivid generate "$_vivid_theme" 2>/dev/null)"
  fi
  unset _vivid_theme
fi

_fzf_color_theme="--color=fg:#878787,fg+:#b3b3b3,bg:-1,bg+:-1 --color=hl:#a69f91,hl+:#dad5c8,info:#414141,marker:#8e8b85 --color=prompt:#eaeaea,spinner:#6c6a65,pointer:#8e8b85,header:#b3b3b3 --color=border:#2a2a2a,label:#b3b3b3,query:#cccccc"
export FZF_DEFAULT_OPTS="${_fzf_color_theme}${FZF_DEFAULT_OPTS:+ ${FZF_DEFAULT_OPTS}}"
unset _fzf_color_theme
