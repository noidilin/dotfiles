export def main [] {
  return [
    # readline completion menu
    {
      name: ide_completion_menu
      modifier: none
      keycode: tab
      mode: [vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: ide_completion_menu }
          { send: menunext }
        ]
      }
    }

    # other readline menu
    {
      name: commands_menu
      modifier: control
      keycode: char_u
      mode: [vi_normal vi_insert]
      event: { send: menu name: commands_menu }
    }
    {
      name: vars_menu
      modifier: control
      keycode: char_v
      mode: [vi_normal vi_insert]
      event: { send: menu name: vars_menu }
    }
    {
      name: help_menu
      modifier: none
      keycode: f9
      mode: [vi_normal vi_insert]
      event: { send: menu name: help_menu }
    }

    # menu behavior
    {
      name: complete_suggestion
      modifier: control
      keycode: char_y
      mode: [vi_normal vi_insert]
      event: { send: enter }
    }
    {
      name: next_page
      modifier: control
      keycode: char_f
      mode: [vi_normal vi_insert]
      event: { send: menupagenext }
    }
    {
      name: previous_page
      modifier: control
      keycode: char_b
      mode: [vi_normal vi_insert]
      event: { send: menupageprevious }
    }

    # menu - fzf
    {
      name: history_menu
      modifier: control
      keycode: char_r
      mode: [vi_normal vi_insert]
      event: {
        send: ExecuteHostCommand
        cmd: "commandline edit --replace (
          history
            | get command
            | reverse
            | uniq
            | str join (char -i 0)
            | fzf
              --multi
              --scheme=history
              --read0
              --layout=reverse
              --height=80%
              --bind=change:top
              -q (commandline)
            | decode utf-8
            | str trim
        )"
      }
    }
    {
      name: fzf_files
      modifier: control
      keycode: char_t
      mode: [vi_normal, vi_insert]
      event: {
        send: executehostcommand
        cmd: "
          let fzf_ctrl_t_command = \$\"($env.FZF_CTRL_T_COMMAND) | fzf ($env.FZF_CTRL_T_OPTS)\";
          let result = nu -l -i -c $fzf_ctrl_t_command;
          commandline edit --append $result;
          commandline set-cursor --end
        "
      }
    }
    {
      name: fzf_dirs
      modifier: alt
      keycode: char_c
      mode: [emacs, vi_normal, vi_insert]
        event: {
          send: executehostcommand
          cmd: "
            let fzf_alt_c_command = \$\"($env.FZF_ALT_C_COMMAND) | fzf ($env.FZF_ALT_C_OPTS)\";
            let result = nu -c $fzf_alt_c_command;
            cd $result;
          "
        }
    }
    {
      name: paste_bash_command
      modifier: alt
      keycode: char_v
      mode: [emacs, vi_normal, vi_insert]
      event: {
        send: ExecuteHostCommand
        cmd: "paste-bash-command"
      }
    }

    # custom menu
    {
      name: reload_config
      modifier: none
      keycode: f8
      mode: [vi_normal vi_insert]
      event: {
        send: ExecuteHostCommand,
        cmd: $"clear;source '($nu.env-path)';source '($nu.config-path)';print 'Config reloaded.\n'"
      }
    }

    # disable default
    {
      name: clear_screen
      modifier: control
      keycode: char_l
      mode: [emacs, vi_normal, vi_insert]
      event: null
    }
  ]
}
