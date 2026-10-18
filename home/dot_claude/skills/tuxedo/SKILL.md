---
name: tuxedo
description: tuxedo todo.txt format — the line grammar and tag schema for the user's task list. Use when adding a task, marking one done, querying what is due or blocked, or when the user mentions tuxedo or todo.txt.
---

**There is more than one list, and `tuxedo` never tells you which one it read.** No listing command prints the path (only `archive` does) and `--json` omits it too, so `TODO: N of M` on its own proves nothing. `~/.zshenv` exports `TODO_FILE` pointing at the personal list (`~/.local/share/tuxedo/todo.txt`); a project may override it for its own git-tracked list via `[env]` in its `mise.toml`.

So **resolve the path before you trust a count**: `mise env | grep TODO_FILE` inside a project, `echo $TODO_FILE` outside one. In a project whose shell is not mise-activated, run `mise exec -- tuxedo ls` so the override applies. Never hardcode `TODO_FILE=~/.local/share/tuxedo/todo.txt` — inside a project with its own list it silently returns the wrong list's state.

A project's list may also use a different tag schema than the one below; that project's `CLAUDE.md` wins.

## Line grammar

Fields are positional and must appear in this order. Everything except the text is optional.

```text
(A) 2026-09-16 索取地端網段與 CGW IP —— S7 施工前置 +acme @email for:client wait:henna due:2026-09-30 id:TK03
```

| 位置 | 欄位 |
| --- | --- |
| 1 | Priority, exactly `(A)` through `(Z)` followed by a space. |
| 2 | Creation date, `YYYY-MM-DD`. |
| 3 | Task text. |
| 4 | Tags and keys — parseable anywhere, written trailing. |

A completed line puts `x` first, then the completion date, then the original creation date, and drops the priority:

```text
x 2026-09-16 2026-01-01 Recurring rent due:2026-10-20 rec:+1m +finance
```

## Tag schema

| 欄位 | 規則 |
| --- | --- |
| `+project` | One per task: the client or engagement. |
| `@mode` | **Exactly one per task.** Live set: `@email` `@report` `@slides` `@meeting` `@research` `@lab` (hands-on console work). |
| `for:` | `client` or `internal` — who the output is for. |
| `id:` | Stable, unique task number, written last on the line. Never renumber an ID once it has appeared outside the list; new IDs take the current maximum + 1. This is the key other files cite, so the task text can be rewritten freely. |
| `wait:` | Owner, lowercase first name. Present = someone else's ball; absent = mine. |
| `ref:` | Optional repo-relative path to a source file. Prefer citing the task's `id:` from that file instead — paths move and frozen documents can't be updated, IDs don't. |
| `due:` | `YYYY-MM-DD`, only for a deadline fixed by someone outside. Ordering otherwise comes from priority, not invented dates. |
| `(A)`/`(B)`/`(C)` | A is load-bearing this week, C is background. |

Reach for an existing `@mode` before coining one — `lsc` is a flat alphabetical list that stops being scannable past about ten entries.

## Keys tuxedo acts on

`due:`, `rec:` and `t:` are interpreted; every other key, including `id:`, `for:`, `wait:` and `ref:`, is passed through untouched, which is what makes the schema above safe to extend.

- **`due:`** orders listings and accepts natural language on `add`.
- **`rec:+1m`** makes the task recur: `done` completes the line and emits a fresh instance with the priority preserved, today as its creation date, and `due:` rolled forward by the interval.
- **`t:`** is inert — a future `t:` date does not hide the task from `ls`.

## `add` rewrites what you pass it

`tuxedo add 'Call Nico tomorrow @email'` stores `2026-09-16 Call Nico @email due:2026-09-17`: today's creation date is injected, and the date word is consumed out of the text into `due:`. Write an explicit `due:YYYY-MM-DD` when the date matters, and expect the stored text to differ from the text you passed.

Use `add` for a single task so the grammar comes out right. For bulk retagging, edit the file directly, then verify with `ls` and confirm the count moved as expected.

## One filterable axis

`@mode` is the only axis that slices reliably, which is the reason each task carries exactly one. Narrow further with `for:`, as in `ls @email for:client`. Three properties of `ls`, none of them in `--help`:

- **Two `@` terms: the last silently wins.** `ls @client @email` returns every `@email` task with `@client` discarded and no warning. Two `+` terms behave the same way.
- **Bare text matches as a fuzzy subsequence**, case- and punctuation-insensitive: `wt`, `wait` and `wait:` all return the same over-broad set, because w→a→i→t need only appear in order somewhere on the line. Full keys like `for:client` or `wait:henna` land precisely; short fragments do not. **`id:` is not exact either**: `ls id:TK3` returns TK3x and any ID with a 3 after TK, 18 lines on an 89-line list. Look an ID up with `grep -E ' id:TK37( |$)' "$TODO_FILE"`, not `ls`.
- Exact by construction: `lsp`, `lsprj`, `lsc`, a single `@mode`, a single `+project`.

Run `tuxedo --help` for the command list; it is current and complete.
