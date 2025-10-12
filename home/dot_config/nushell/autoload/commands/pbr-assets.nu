# Run from inside a category folder like "wood"

def pbr_move_preview [] {
  # Loop through each category folder (e.g. 01, 02, etc.)
  ls | where type == 'dir' | each {|category|
    let category_path = $category.name
    let preview_path  = $category_path | path join 'data' 'previews' 'default'

    if ($preview_path | path exists) {
      let preview_file = (ls $preview_path | where type == 'file' | get 0)

      if $preview_file != null {
        print $"moving preview file: ($preview_file.name)"
        cp $preview_file.name $category_path
      }
    }
  }
}

def pbr_cleanup_folder [] {
  # Loop through each category folder (e.g. 01, 02, etc.)
  ls | where type == 'dir' | each {|category|
    let category_path = $category.name
    let data_path = $category_path | path join 'data'
    let 8k_path = $category_path | path join '8k'
    let 6k_path = $category_path | path join '6k'

    if ($data_path | path exists) {
      print $"deleting data folder: ($data_path)"
      rm -r $data_path
    }

    if ($8k_path | path exists) {
      print $"deleting folder: ($8k_path)"
      rm -r $8k_path
    }

    if ($6k_path | path exists) {
      print $"deleting folder: ($6k_path)"
      rm -r $6k_path
    }
  }
}

def pbr_organize [] {
  pbr_move_preview
  pbr_cleanup_folder
}
