def replace_mocha_palette [
    file_path: string, 
    --stylus (-s)
] {
    # since nu will convert json into 'record' data type, which can't be piped into `str` command
    # add '--raw' tag to read the file as raw text.
    let original = (open --raw $file_path | collect)

    # Apply mandatory replacements
    let temp = $original 
        | str replace --all '#f5c2e7' '#9f9fbd'
        | str replace --all '#cba6f7' '#797994'
        | str replace --all '#f38ba8' '#b07878'
        | str replace --all '#eba0ac' '#cc9393'
        | str replace --all '#fab387' '#d6caab'
        | str replace --all '#f9e2af' '#ebd6b7'
        | str replace --all '#a6e3a1' '#778777'
        | str replace --all '#94e2d5' '#9bb09b'
        | str replace --all '#89dceb' '#92b3b3'
        | str replace --all '#74c7ec' '#769494'
        | str replace --all '#89b4fa' '#7d96ad'
        | str replace --all '#b4befe' '#9db2cf'
        | str replace --all '#cdd6f4' '#b3b3b3'
        | str replace --all '#bac2de' '#9d9d9d'
        | str replace --all '#a6adc8' '#878787'
        | str replace --all '#9399b2' '#707070'
        | str replace --all '#7f849c' '#5d5d5d'
        | str replace --all '#6c7086' '#4e4e4e'
        | str replace --all '#585b70' '#414141'
        | str replace --all '#45475a' '#353535'
        | str replace --all '#313244' '#2a2a2a'
        | str replace --all '#1e1e2e' '#1e1e1e'
        | str replace --all '#181825' '#191919'
        | str replace --all '#11111b' '#151515'

    # Additional replacements if --stylus is used
    let result = if $stylus {
        $temp
            | str replace --all '"updateInterval":24,"updateOnlyEnabled":true' '"updateInterval":0,"updateOnlyEnabled":true'
            | str replace --all '"name":"accentColor","value":null' '"name":"accentColor","value":"rosewater"'
            | str replace --all '#f5e0dc' '#faf5eb'
            | str replace --all '#f2cdcd' '#dad5c8'
    } else {
        $temp
            | str replace --all '#f5e0dc' '#dcb5a5'
            | str replace --all '#f2cdcd' '#c8a492'
    }

    $result | save --force $file_path
}

def stylus-update [
  accent: string = 'rosewater'
  lib: string = 'https://noidilin.github.io/color-fatigue/lib/lib.less'
] {
  let url: string = 'https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json'
  let file = ( $env.USERPROFILE | path join '.local/etc/stylus/color-fatigue.json' )
  
  # First, let's see what we're working with
  let data = (http get $url | decode utf-8 | from json)
  
  # Check if it's wrapped in an object or is a direct array
  let json_data = (
    if ($data | describe) =~ "list" {
      # It's an array, process directly
      $data | each { |style| 
        if ($style | get --optional usercssData.vars.accentColor) != null {
          $style | update usercssData.vars.accentColor.value $accent
        } else {
          $style
        }
      }
    } else {
      # It might be wrapped, adjust as needed
      $data
    }
    | to json --indent 2
  )
  
  $json_data
    | str replace --all "https://userstyles.catppuccin.com/lib/lib.less" $lib
    | save --force $file
  
  print $"✓ Created ($file) with ($accent) accent"
}

def stylus-examine [] {
  let file_content = (open ~/.local/etc/stylus/color-fatigue.json)

  print "=== Verification Summary ==="
  print $"Total styles: ($file_content | length)"
  print $"Accent colors: ($file_content | each { |s| $s.usercssData?.vars?.accentColor?.value } | uniq)"
  print $"Custom lib URL present: ($file_content | to json | str contains 'noidilin.github.io/color-fatigue')"
  print $"Old lib URL present: ($file_content | to json | str contains 'userstyles.catppuccin.com')"
}

# Carapace styling function (can be called manually to customize)
def style-carapace [] {
  carapace --style "carapace.Description=fg-#4e4e4e,italic"
  carapace --style "carapace.Error=fg-#b07878,bold"
  carapace --style "carapace.Usage=fg-#9d9d9d"
  carapace --style "carapace.Value=fg-#878787"
  carapace --style "carapace.FlagArg=fg-#707070"
  carapace --style "carapace.FlagMultiArg=fg-#707070"
  carapace --style "carapace.FlagNoArg=fg-#5d5d5d"
  carapace --style "carapace.FlagOptArg=fg-#5d5d5d"
  carapace --style "carapace.Highlight1=fg-#dcdcdc"
  carapace --style "carapace.Highlight2=fg-#c0c0c0"
  carapace --style "carapace.Highlight3=fg-#aaaaaa"
  carapace --style "carapace.Highlight4=fg-#8e8e8e"
  carapace --style "carapace.Highlight5=fg-#7f7f7f"
  carapace --style "carapace.Highlight6=fg-#686868"
  carapace --style "carapace.Highlight7=fg-#7b7974"
  carapace --style "carapace.Highlight8=fg-#8e8b85"
  carapace --style "carapace.Highlight9=fg-#97948c"
  carapace --style "carapace.Highlight10=fg-#a19d97"
  carapace --style "carapace.Highlight11=fg-#b4b0a7"
  carapace --style "carapace.Highlight12=fg-#bdbab2"
  carapace --style "carapace.KeywordAmbiguous=fg-#5d5d5d"
  carapace --style "carapace.KeywordNegative=fg-#c8a492"
  carapace --style "carapace.KeywordPositive=fg-#778777"
  carapace --style "carapace.KeywordUnknown=fg-#4e4e4e"
  carapace --style "carapace.LogLevelCritical=fg-#b07878,bold"
  carapace --style "carapace.LogLevelDebug=fg-#707070"
  carapace --style "carapace.LogLevelError=fg-#b07878"
  carapace --style "carapace.LogLevelFatal=fg-#b07878,bold"
  carapace --style "carapace.LogLevelInfo=fg-#4e4e4e"
  carapace --style "carapace.LogLevelTrace=fg-#5d5d5d"
  carapace --style "carapace.LogLevelWarning=fg-#c8a492"
}
