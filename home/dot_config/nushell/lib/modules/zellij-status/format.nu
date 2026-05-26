# Shared formatting helpers for compact Zellij display labels.

const ZELLIJ_LABEL_MAX = 20

# Keep labels compact enough for tab bars and status segments.
export def shorten [name: string] {
    if ($name | str length) > $ZELLIJ_LABEL_MAX {
        let prefix = ($name | str substring 0..16)
        $"($prefix)..."
    } else {
        $name
    }
}
