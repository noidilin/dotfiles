$env.FZF_DEFAULT_COMMAND = "fd --hidden --strip-cwd-prefix --exclude .git"
$env.FZF_CTRL_T_COMMAND = "fd --type file --hidden --strip-cwd-prefix --exclude .git"
$env.FZF_ALT_C_COMMAND = "fd --type directory --hidden --strip-cwd-prefix --exclude .git"

# generated theme permalink: https://vitormv.github.io/fzf-themes#eyJib3JkZXJTdHlsZSI6InJvdW5kZWQiLCJib3JkZXJMYWJlbCI6ImZ6ZiIsImJvcmRlckxhYmVsUG9zaXRpb24iOjAsInByZXZpZXdCb3JkZXJTdHlsZSI6InJvdW5kZWQiLCJwYWRkaW5nIjoiMiIsIm1hcmdpbiI6IjIiLCJwcm9tcHQiOiI+ICIsIm1hcmtlciI6Ij4iLCJwb2ludGVyIjoi4peGIiwic2VwYXJhdG9yIjoi4pSAIiwic2Nyb2xsYmFyIjoi4pSCIiwibGF5b3V0IjoicmV2ZXJzZSIsImluZm8iOiJyaWdodCIsImNvbG9ycyI6ImZnOiM4ZThlOGUsZmcrOiNiM2IzYjMsYmc6IzE5MTkxOSxiZys6IzE5MTkxOSxobDojYTY5ZjkxLGhsKzojZGFkNWM4LGluZm86IzQ3NDc0NyxtYXJrZXI6I2IzYWQ5Zixwcm9tcHQ6I2VhZWFlYSxzcGlubmVyOiM3MDZjNjIscG9pbnRlcjojOGU4OTdkLGhlYWRlcjojYjNiM2IzLGJvcmRlcjojMmEyYTJhLGxhYmVsOiNiM2IzYjMscXVlcnk6I2RjZGNkYyJ9 
# bg set to -1 will use the terminal default bg color
$env.FZF_DEFAULT_OPTS = [
    "--color=fg:#878787,fg+:#b3b3b3,bg:-1,bg+:-1"
    "--color=hl:#a69f91,hl+:#dad5c8,info:#414141,marker:#8e8b85"
    "--color=prompt:#eaeaea,spinner:#6c6a65,pointer:#8e8b85,header:#b3b3b3"
    "--color=border:#2a2a2a,label:#b3b3b3,query:#cccccc"
    "--padding='2' --margin='2' --layout=reverse --info='right'"
    "--prompt='> ' --marker='>' --pointer='◆' --separator='─' --scrollbar='│'"
    "--border='rounded' --border-label='fzf' --border-label-pos='0'"
    "--cycle --scroll-off=5"
    "--preview-window=right,60%,border-left"
    "--bind ctrl-u:preview-half-page-up"
    "--bind ctrl-d:preview-half-page-down"
    "--bind ctrl-f:preview-page-down"
    "--bind ctrl-b:preview-page-up"
    "--bind ctrl-g:preview-top"
    "--bind ctrl-h:preview-bottom"
    "--bind alt-w:toggle-preview-wrap"
    "--bind ctrl-e:toggle-preview"
] | str join " "

$env.FZF_CTRL_T_OPTS = "--height 80% --preview 'bat -n --color=always --line-range=:500 {}'"
$env.FZF_ALT_C_OPTS = "--height 80% --preview 'eza --tree --level=2 --color=always {} '"
