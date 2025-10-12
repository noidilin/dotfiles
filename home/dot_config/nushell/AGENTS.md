# Agent Guidelines for Nushell Config

## Testing & Validation

- Test config: `nu -c 'source config.nu; print "ok"'` or reload shell
- Test single module: `nu -c 'use scripts/commands.nu; print "ok"'`
- No formal test suite - validate by loading in a fresh Nushell instance

## File Structure & Load Order

1. `config.nu` - Main config, imports modules, sources scripts
2. `config/` - Modularized config (completions, theme, menus, keybindings)
3. `env/` - Static environment variables
4. `autoload/` - Files in this dir will be auto-loaded during startup
5. `lib/` - Added to `$env.NU_LIB_DIRS`

> [!WARNING] autoload feature
> The autoload files will be loaded when you:
>
> - Start a normal Nushell session: `nu`
> - Start a login shell: `nu -l`
> - Use an interactive REPL

## Code Style

- **Imports**: Use `use` for modules with exports, `source` for scripts without exports
- **Module structure**: Create `mod.nu` with `export module` statements
- **Constants**: Use `const` for paths consumed by `use` and `source`
- **Environment**: Set in `$env.VAR` format, use `load-env` for bulk updates
- **Functions**: Use `def` for commands, `def --env` for environment-modifying commands
- **Naming**: snake_case for functions/variables, SCREAMING_SNAKE for env vars
- **Error handling**: Use optional operators (`?.`, `--optional`) and null checks
- **Pipes**: Nushell is pipe-first; chain operations with `|`
- **Strings**: Use double quotes for strings, `$"..."` for interpolation
- **Comments**: Use `#` for single-line comments, document complex logic
