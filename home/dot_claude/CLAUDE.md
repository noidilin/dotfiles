# Global instructions

## Prefer a `mise.toml` per project

Broad pattern, not a strict rule - a project generally wants a `mise.toml` pinning:

- `[tools]` for tools it can't run without — infra binaries, language runtimes, and package managers alike
- `[env]` for anything the project shouldn't inherit from ambient shell state, such as `AWS_PROFILE` and `AWS_REGION`, defaulting to the least-privileged profile

`mise.toml` is additive operator config — don't edit a project's own source, IaC, or scripts to accomplish this.
