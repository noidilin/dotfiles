# Developer home-directory relocation research

Research date: 2026-10-25

Scope: relocating npm, Docker CLI, CocoaPods, and Terraform plugin state into `~/.dev`, plus evaluating Expo and Swift Package Manager state under top-level dot-directories in `$HOME`.

## Summary

| Tool | Relocation support | Recommendation |
|---|---|---|
| npm | Official `NPM_CONFIG_*` settings | Relocate cache, user config, and global prefix separately. Treat npmrc as sensitive and do not automatically migrate global packages. |
| Docker CLI | Official `DOCKER_CONFIG` support | Relocate cautiously. It reliably covers Docker CLI state, but not every Docker Desktop or third-party file currently under `~/.docker`. |
| CocoaPods | Official `CP_HOME_DIR` support | Relocate its home to `~/.dev/cocoapods`, preserving any existing `~/.cocoapods`. |
| Terraform | CLI configuration supports `plugin_cache_dir` | Keep the cache path authoritative in `config.tfrc` and disable checkpoints there. |
| Expo CLI | Internal `__UNSAFE_EXPO_HOME_DIRECTORY` escape hatch | Do not treat as stable configuration. It is intentionally marked unsafe/internal and is not honored by every Expo command/package. |
| SwiftPM | Official per-command path flags; XDG support in current source | Do not force into `~/.dev` globally. Use its XDG/platform-native locations; the top-level `~/.swiftpm` directory is partly a compatibility symlink hub. |

## npm

npm uses separate settings for its cache, user configuration, and global installation prefix:

```yaml
NPM_CONFIG_CACHE: [".dev", "npm", "cache"]
NPM_CONFIG_USERCONFIG: [".dev", "npm", "npmrc"]
NPM_CONFIG_PREFIX: [".dev", "npm", "prefix"]
NPM_BIN_HOME: [".dev", "npm", "prefix", "bin"]
```

The resulting destinations are:

- cache and logs: `~/.dev/npm/cache`;
- user configuration: `~/.dev/npm/npmrc`;
- global packages: `~/.dev/npm/prefix`;
- global executables: `~/.dev/npm/prefix/bin`.

`NPM_BIN_HOME` is a repository PATH helper rather than an npm-native setting. Changing `NPM_CONFIG_PREFIX` does not migrate packages installed under the old global prefix; reinstall required global packages instead of moving the prefix contents blindly.

The old `~/.npm` directory is disposable cache and can be left in place. An existing `~/.npmrc` may contain registry tokens and must never be printed, committed, or overwritten. This Nushell migration refuses to overwrite an existing destination:

```nu
let source = ($nu.home-dir | path join ".npmrc")
let destination = ($nu.home-dir | path join ".dev" "npm" "npmrc")
mkdir ($destination | path dirname)
if ($source | path exists) and not ($destination | path exists) {
    mv $source $destination
}
```

Keep the old file when the destination already exists and reconcile it manually without exposing credentials. The old `~/.npm` cache and packages under the previous global prefix are deliberately not migrated.

Validate without displaying configuration contents:

```sh
npm config get cache
npm config get userconfig
npm config get prefix
npm prefix --global
npm root --global
```

## Docker

### What `DOCKER_CONFIG` officially relocates

Docker documents `DOCKER_CONFIG` as the location of Docker **client configuration files**, replacing the default `~/.docker`. The global `--config` option overrides the environment variable for one invocation.

The Docker CLI configuration directory includes or influences:

- `config.json`, including registry authentication or credential-helper configuration;
- Docker contexts and their TLS metadata;
- client TLS files and registry certificate material;
- CLI-plugin configuration;
- Buildx state by default.

Buildx documents this lookup order for its configuration, state, and logs:

1. `$BUILDX_CONFIG`
2. `$DOCKER_CONFIG/buildx`
3. `~/.docker/buildx`

Therefore, setting only `DOCKER_CONFIG=$HOME/.dev/docker` should also move normal Buildx state to `~/.dev/docker/buildx` unless `BUILDX_CONFIG` is separately set.

Sources:

- [Docker CLI configuration and `DOCKER_CONFIG`](https://docs.docker.com/reference/cli/docker/#configuration-files)
- [Docker Buildx `BUILDX_CONFIG` lookup order](https://docs.docker.com/build/building/variables/#buildx_config)
- [Docker contexts](https://docs.docker.com/engine/context/working-with-contexts/)

### Consequences and limitations

`DOCKER_CONFIG` is documented for the **Docker command-line client**, not as a promise that every Docker product writes all state there. The current `~/.docker` on this machine contains both ordinary CLI state and product-specific state:

- CLI-oriented: `config.json`, `contexts`, `buildx`, `cli-plugins`;
- product/extension-oriented: `desktop-build`, `docker-next`, `mutagen`, `sandboxes`, `models`, `cagent`, `run`, token-seed files, and `bin`.

The second group is not covered by Docker's documented `DOCKER_CONFIG` contract. Docker Desktop, Docker extensions, Model Runner, cagent, or other components may continue to recreate `~/.docker`, especially when launched as macOS GUI applications that do not inherit the shell/mise environment.

Practical risks:

1. **Split configuration:** GUI-launched Docker Desktop or OrbStack may update `~/.docker`, while terminal Docker commands read `~/.dev/docker`.
2. **Missing contexts:** if a desktop runtime creates a context in the default directory but the CLI reads the relocated directory, the context may not appear until imported or recreated.
3. **Credential mismatch:** `config.json` selects credential helpers and can contain authentication data. If two config directories exist, login state may differ between tools.
4. **Third-party assumptions:** tools that directly read `~/.docker/config.json` instead of invoking Docker or honoring `DOCKER_CONFIG` will not see the relocated credentials/configuration.
5. **GUI environment propagation:** configuring `DOCKER_CONFIG` only through mise is insufficient for apps launched from Finder, Spotlight, Dock, or login items.
6. **Sensitive data:** Docker warns that the configuration directory can contain registry credentials and proxy authentication. The relocated directory must remain private and must not be committed by chezmoi.

### Docker recommendation

Relocate Docker CLI state, but do not assume this will permanently eliminate `~/.docker`:

```yaml
DOCKER_CONFIG: [".dev", "docker"]
```

Migration procedure:

1. Quit Docker Desktop and OrbStack.
2. Create `~/.dev/docker` with user-only permissions.
3. Move only CLI-owned entries that do not already exist at the destination:

   ```nu
   let old = ($nu.home-dir | path join ".docker")
   let new = ($nu.home-dir | path join ".dev" "docker")
   mkdir $new

   for name in [config.json contexts buildx cli-plugins] {
       let source = ($old | path join $name)
       let destination = ($new | path join $name)
       if ($source | path exists) and not ($destination | path exists) {
           mv $source $destination
       }
   }
   ```

4. Ensure `DOCKER_CONFIG` reaches both shells and GUI/login-session processes.
5. Restart the container runtime and verify `docker context ls`, `docker buildx ls`, Compose, login state, and credential-helper behavior without displaying `config.json`.
6. Observe which product-specific entries are recreated under `~/.docker` before deciding whether the relocation meets the aesthetic goal.

Avoid blindly moving the entire existing directory: several current entries are outside the documented Docker CLI configuration contract.

## Expo

### Current Expo CLI behavior

Expo CLI source defines `getExpoHomeDirectory()` with a shell-only environment escape hatch:

```text
__UNSAFE_EXPO_HOME_DIRECTORY
```

The source explicitly says:

- it redirects the authentication-token cache and other settings;
- it is read before project dotenv processing;
- the `__UNSAFE_` prefix marks it as a shell-only escape hatch;
- project `.env` files must not be allowed to redirect credentials.

The directory includes `state.json`, which can contain the Expo authentication session, plus caches such as code-signing, simulator app, schema, and version caches.

Source: [Expo CLI `UserSettings.ts`](https://github.com/expo/expo/blob/main/packages/%40expo/cli/src/api/user/UserSettings.ts)

### Why it is not a complete or stable relocation mechanism

Other first-party Expo packages do not consistently use that escape hatch. For example, `create-expo` independently computes `~/.expo` from `os.homedir()` and only branches for Expo staging/local modes. It does not read `__UNSAFE_EXPO_HOME_DIRECTORY`.

Source: [`create-expo` paths](https://github.com/expo/expo/blob/main/packages/create-expo/src/paths.ts)

Consequences:

- `npx expo` may use the relocated location, while `create-expo`, older Expo tooling, EAS versions, or related packages may still recreate `~/.expo`.
- The variable is deliberately named as an unsafe/internal escape hatch and is not documented as a stable public user setting.
- The relocated directory includes authentication material, so it should not be managed or committed by chezmoi.
- Project-local `.expo` directories are unrelated and remain inside each project.

### Expo recommendation

Do **not** add Expo relocation to the durable cross-platform environment contract yet. Keeping `~/.expo` is more reliable.

If experimentation is acceptable, this can be tested in a shell-only environment:

```text
__UNSAFE_EXPO_HOME_DIRECTORY=$HOME/.dev/expo
```

Treat it as version-sensitive and expect some Expo commands to recreate `~/.expo`. It should not be placed in project `.env` files.

## Swift Package Manager

### Current path model

Current SwiftPM source supports `XDG_CONFIG_HOME` for its compatibility/root directory:

- `$XDG_CONFIG_HOME/swiftpm` when `XDG_CONFIG_HOME` exists;
- otherwise `~/.swiftpm`.

On macOS, SwiftPM uses platform-native directories for much of its actual data:

- cache: `~/Library/Caches/org.swift.swiftpm`;
- configuration/security/SDK data: under `~/Library/org.swift.swiftpm`;
- compatibility links are created in the SwiftPM root directory.

The current machine confirms that `~/.swiftpm/cache`, `configuration`, and `security` are symbolic links into those macOS `Library` locations rather than the primary data itself.

Source: [SwiftPM filesystem path implementation](https://github.com/swiftlang/swift-package-manager/blob/main/Sources/Basics/FileSystem/FileSystem%2BExtensions.swift)

### Supported overrides

SwiftPM officially exposes command-line options:

```text
--cache-path
--config-path
--security-path
--scratch-path
--swift-sdks-path
```

These are invocation flags, not general environment variables equivalent to `DOCKER_CONFIG`. They are accepted by `swift package` commands, but a shell alias or wrapper cannot guarantee that Xcode and every tool invoking SwiftPM will use them.

Sources:

- [SwiftPM command documentation](https://docs.swift.org/latest/documentation/packagemanagerdocs/packageconfiggetmirror/)
- [SwiftPM location options source](https://github.com/swiftlang/swift-package-manager/blob/main/Sources/CoreCommands/Options.swift)

### Consequences of forcing SwiftPM into `~/.dev`

1. A wrapper around `swift package` would not affect Xcode's internal SwiftPM invocations.
2. Different callers could read different registry, mirror, fingerprint, signing-entity, and cache locations.
3. Security state under the security directory is important for package-registry fingerprint/signature validation; splitting it can produce repeated trust prompts or inconsistent verification history.
4. Overriding `XDG_CONFIG_HOME` to `~/.dev` would move every XDG-aware application, not just SwiftPM.
5. Existing top-level `~/.swiftpm` entries may be compatibility symlinks rather than clutter containing real data.

### SwiftPM recommendation

Do not add a SwiftPM-specific `~/.dev` relocation. Keep the current global XDG variables and let SwiftPM use its platform-native directories.

After ensuring `XDG_CONFIG_HOME` reaches GUI/Xcode processes, test whether the old `~/.swiftpm` is recreated. Because its current entries are symlinks into `~/Library`, it may be removable as stale compatibility state, but Xcode or a process without the XDG environment may recreate it.

## CocoaPods

Set `CP_HOME_DIR=$HOME/.dev/cocoapods`. Preserve an existing `~/.cocoapods`; do not automatically delete it or overwrite destination data. A manual Nushell migration can move it only when the destination is absent:

```nu
let source = ($nu.home-dir | path join ".cocoapods")
let destination = ($nu.home-dir | path join ".dev" "cocoapods")
if ($source | path exists) and not ($destination | path exists) {
    mv $source $destination
}
```

After migration, `pod env` can be used to confirm the active CocoaPods home without changing repository-managed files.

## Terraform plugin cache

Keep Terraform's provider cache authoritative in `~/.config/terraform/config.tfrc` rather than adding `TF_PLUGIN_CACHE_DIR`:

```hcl
plugin_cache_dir   = "$HOME/.dev/terraform/plugin-cache"
disable_checkpoint = true
```

The old cache is disposable but should not be removed automatically. `terraform version` provides a non-destructive runtime check; the rendered configuration should also be inspected directly to confirm the exact cache and checkpoint settings.

## Recommended management changes

Environment configuration:

```yaml
env:
  dev:
    DOCKER_CONFIG: [".dev", "docker"]
    CP_HOME_DIR: [".dev", "cocoapods"]
    NPM_CONFIG_CACHE: [".dev", "npm", "cache"]
    NPM_CONFIG_USERCONFIG: [".dev", "npm", "npmrc"]
    NPM_CONFIG_PREFIX: [".dev", "npm", "prefix"]
    NPM_BIN_HOME: [".dev", "npm", "prefix", "bin"]
```

Create the runtime directories idempotently from declarative data, but do not manage their generated contents with chezmoi:

- `~/.dev/npm/cache`
- `~/.dev/npm/prefix/bin`
- `~/.dev/docker`
- `~/.dev/cocoapods`
- `~/.dev/terraform/plugin-cache`

Safe Docker migration is manual: quit Docker Desktop and OrbStack, verify that each destination is absent, and move only `config.json`, `contexts`, `buildx`, and user-installed `cli-plugins` without force or overwrite options. Leave all product-specific entries under `~/.docker` untouched. Docker Desktop and third-party tools, especially GUI-launched processes that do not inherit the shell environment, may recreate `~/.docker`.

Validation commands:

```sh
npm config get cache
npm config get userconfig
npm config get prefix
docker context ls
docker buildx ls
pod env
terraform version
```

Do not add Expo or SwiftPM relocation variables to the stable environment list at this time.
