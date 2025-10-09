# dotfile

> [!WARNING] platform
> currently only works on windows

## install scripts

The `.install` dir contains all the installation scripts that can setup environment variables, daily used apps and symlinks. The scripts are wrote in `pwsh` since it is the modern shell language in windows, and is more verbose but clear for me.

- `init`: setup buckets and install `git`, `chezmoi`, `pwsh`, `nu`, `age`
- `env`: setup environment variable and PATH
- `symlinks`: setup symbolic links
  - for apps that won't utilize `XDG` dir, and depends on the original config dir to work.
- `scoop`: install apps with `scoop`
- `pnpm`: install `pnpm` packages globally
- `winget`: install apps with `winget`

> [!note] XDG directory
> It will affect app storing location of config, data and cache, like neovim, lazygit...
> Unfortunately, vs code don't utilize these env variables by default now (2024-11-27).
> Hence, I've manually add those environment variables in the `settings.json`.
>
> It is still not clear that whether:
>
> - it is a vs code issue
> - it's because I install vs code with `scoop`.

### batch scripts

In addition, `batch` scripts streamline all the installation scripts. However, it requires setting up private `ssh` key, which is currently stored in USB flash drive, since I couldn't think of a valid way to save the private key.

> [!warning] UAC prompt
> There will be UAC prompt asking for admin privilege during some installation, mostly from `winget install` and `scoop install neorocks-scoop/luarocks`.
> Since UAC prompt has to be interact with the GUI manually, which makes the scripts not so automatical.

- [ ] use cache feature in `gsudo` to reduce multiple UAC prompt into one.

---

## Setup age Keys

Since I stored some api keys for AI chat bot in my dotfiles, I encrypted it with `chezmoi` using `age` encryption. However, `chezmoi` needs to setup a `age` private key first to encrypt and decrypt the secret files.

reference: [Encryption - chezmoi](https://www.chezmoi.io/user-guide/frequently-asked-questions/encryption/)

The strategy:

### 1. Generate an age private key, which will be used to encrypt and decrypt secrets

```sh
chezmoi cd ~
age-keygen | age --armor --passphrase > key.txt.age
```

> [!hint] the mysterious key.txt
> The 'key.txt' will be the private key to encrypt and decrypt files processed with `chezmoi add --encrypt {file}`
> I can further encrypt this private key with a passphrase to safely save it to remote repo.
> The passphrase will be used to decrypt the private key when setting up a new device.

### 2. Setup `chezmoi` script template to decrypt the private key if needed

```sh
# pseudo code
# check if the key exist
# `mkdir` for the key's parent dir
# `chezmoi age decrypt --output {private-key} --passphrase {encrypted-private-key}`
# set private key permission `chmod 600 {private-key}`
```

### 3. Configure `chezmoi.toml` to use the private key, and `age` encryption

```toml
encryption = "age"
[age.identity]: private key path
[age.recipient]: public key of the private key
```

### 4. Add my secret files with encryption

```sh
chezmoi add --encrypt {file}
```
