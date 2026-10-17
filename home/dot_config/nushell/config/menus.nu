export def main [] {
  let menu_style = {
    text: { fg: "#707070" }
    match_text: { attr: u }
    description_text: { fg: "#5d5d5d" attr: i }
    selected_text: { fg: "#b3b3b3" bg: "#353535" }
    selected_match_text: { fg: "#cccccc" bg: "#353535" attr: u }
  }

  return [
    {
      name: completion_menu
      only_buffer_difference: false
      marker: ""
      type: {
        layout: columnar
        columns: 4
        col_width: 20
        col_padding: 2
      }
      style: $menu_style
    }
    {
      name: ide_completion_menu
      only_buffer_difference: false
      marker: ""
      type: {
        layout: ide
        min_completion_width: 25       # Ensure min width for readability
        max_completion_width: 50       # Wider completion area
        max_completion_height: 10      # More visible items
        padding: 3                     # More breathing room
        description_mode: "prefer_right"
        min_description_width: 25      # Readable descriptions
        max_description_width: 50      # More space for docs
        max_description_height: 10     # Taller description area
        description_offset: 2          # More separation
        border: false
        cursor_offset: 0
        correct_cursor_pos: false
      }
      style: $menu_style
    }
    {
      name: help_menu
      only_buffer_difference: true
      marker: ""
      type: {
        layout: description
        columns: 4
        col_width: 20
        col_padding: 2
        selection_rows: 4
        description_rows: 10
      }
      style: $menu_style
    }
    {
      name: commands_menu
      only_buffer_difference: false
      marker: ""
      type: {
        layout: columnar
        columns: 4
        col_width: 20
        col_padding: 2
      }
      style: $menu_style
      source: { |buffer, place|
        scope commands
          | where name =~ $buffer
          | each { |it| {value: $it.name description: $it.description} }
      }
    }
    {
      name: vars_menu
      only_buffer_difference: true
      marker: ""
      type: {
        layout: list
        page_size: 10
      }
      style: $menu_style
      source: { |buffer, place|
        scope variables
          | where name =~ $buffer
          | sort-by name
          | each { |it| {value: $it.name description: $it.type} }
      }
    }
  ]
}
