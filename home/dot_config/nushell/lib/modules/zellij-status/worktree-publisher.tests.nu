use std/assert
use ./worktree-publisher.nu

assert equal (worktree-publisher sanitize " feature\nbranch::name ") "feature branch∷name"
assert equal (worktree-publisher pipe-payload " main") "zjstatus::pipe::worktree:: main"

let first_update = (worktree-publisher plan-pipe-update " main" false)
assert equal $first_update.should_publish true
assert equal $first_update.payload "zjstatus::pipe::worktree:: main"
assert equal $first_update.label " main"

let duplicate_update = (worktree-publisher plan-pipe-update " main" true)
assert equal $duplicate_update.should_publish false
assert equal $duplicate_update.payload ""
