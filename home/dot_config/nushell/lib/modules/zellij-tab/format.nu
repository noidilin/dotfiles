# Shared formatting helpers for Zellij tab names.

const ZTAB_NAME_MAX = 20

# Keep names compact enough for tab bars.
export def shorten [name: string] {
    if ($name | str length) > $ZTAB_NAME_MAX {
        let prefix = ($name | str substring 0..16)
        $"($prefix)..."
    } else {
        $name
    }
}
