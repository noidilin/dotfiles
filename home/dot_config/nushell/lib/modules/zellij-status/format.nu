const ZELLIJ_LABEL_MAX = 20

export def shorten [name: string] {
    if ($name | str length) > $ZELLIJ_LABEL_MAX {
        let prefix = ($name | str substring 0..16)
        $"($prefix)..."
    } else {
        $name
    }
}
