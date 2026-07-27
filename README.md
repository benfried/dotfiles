# dotfiles

A repository for, and scripts to organize, my dotfiles.

Config files live in `.dotfiles/` and are symlinked into `$HOME` by
`install.sh`. Works on macOS and Linux.

## Layout

| Path | What |
|---|---|
| `.dotfiles/` | the config files themselves, symlinked into `~` |
| `lib/elisp/` | custom Emacs Lisp, copied to `~/lib` |
| `Library/` | macOS user Library settings (fonts, prefs, keyboard layouts) |
| `Brewfile` / `Ports` | package lists for Homebrew / MacPorts |
| `install.sh` | the installer |
| `setup-gcp-ssh.sh` | registers this machine's SSH key with the GCP VMs |

## Installing on a new machine

`install.sh` **backs up and then deletes** the existing dotfiles in `$HOME`.
The backup goes to `~/.dotfiles/<timestamp>/`. Read that sentence twice before
running it on a machine with configuration you care about.

Prerequisites: **`git` is required** and checked before anything destructive
happens. `zsh`, `tmux`, `fortune`, and `keychain` are used by the configs — the
installer warns about them but continues, and logins will emit complaints until
they exist.

### macOS

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/benfried/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles && ./install.sh
brew bundle install --file=Brewfile
```

(`brew bundle` needs `--file=`; a bare path argument is a usage error.)

### Linux

```sh
sudo apt install -y git zsh tmux fortune-mod keychain     # or the local equivalent
git clone https://github.com/benfried/dotfiles.git ~/src/dotfiles
cd ~/src/dotfiles && ./install.sh
chsh -s "$(command -v zsh)"                               # .zprofile/.zshrc only apply to zsh
```

The installer picks `.tmux.conf.mac` or `.tmux.conf.non-mac` by `uname`, and the
shell configs gate macOS-only paths (Homebrew, MacPorts, OrbStack, iTerm2) on
existence, so the same tree works on both.

## How `~/.ssh` is handled

`~/.ssh` is **not** symlinked as a whole directory. The installer creates it as
a real directory (mode 700) and links only two non-secret files out of the repo:

- `~/.ssh/config` → `.dotfiles/.ssh/config`
- `~/.ssh/known_hosts` → `.dotfiles/.ssh/known_hosts`

Private keys and `authorized_keys` stay local to the machine and never enter the
git tree. This matters most on a GCE VM, where `google-guest-agent` continuously
rewrites `~/.ssh/authorized_keys` from instance metadata — if `~/.ssh` pointed
into the repo, that machine-owned file would land in version control, and
sshd's `StrictModes` would then have to be satisfied by every parent directory
of the repo or key authentication breaks entirely.

`.gitignore` is deny-by-default under `.dotfiles/.ssh/`: everything is ignored
except `config`, `known_hosts`, and `*.pub`.

If `install.sh` reports that `~/.ssh` is a symlink, that's the old layout. It
refuses to migrate automatically, because relocating private key material should
be deliberate. Follow the instructions it prints.

## GCP VM access

Project `deal-tools`, currently one instance: `carbonsteel` in `us-central1-f`.

After installing, on each new machine:

```sh
gcloud auth login          # the bootstrap credential — browser SSO
./setup-gcp-ssh.sh         # generate this machine's key, register it
ssh carbonsteel
```

`setup-gcp-ssh.sh` is idempotent. It generates `~/.ssh/google_compute_engine`
(Ed25519) if absent, prompting for a passphrase, then appends the public half to
the instance's `ssh-keys` metadata. It exits cleanly with instructions if gcloud
is missing or unauthenticated, which is the normal state during a fresh install.

Connections go over an **IAP tunnel** rather than the external IP, because that
IP is ephemeral and changes on every stop/start — the `ProxyCommand` in
`.ssh/config` resolves by instance *name*, which is stable. This needs
`roles/iap.tunnelResourceAccessor` and no inbound firewall rule beyond the IAP
range `35.235.240.0/20`.

### Adding another VM

Two edits:

1. Add a `name:zone` line to the `INSTANCES` array at the top of
   `setup-gcp-ssh.sh`.
2. Copy the `carbonsteel` block in `.dotfiles/.ssh/config`, changing the host
   name and `--zone`.

### Why not just `gcloud compute ssh`?

It works, but it registers keys under your *local* username in **project**
metadata. These configs log in as `ben`, whose keys live in **instance**
metadata, so gcloud's registration doesn't grant access to the account we want.
That mismatch shows up as `Permission denied (publickey)` even though gcloud
reported success.

Note that `gcloud compute instances add-metadata` **replaces** the entire
`ssh-keys` value. `setup-gcp-ssh.sh` reads, appends, and writes back the whole
thing; passing only the new key would silently delete every other machine's
access.

## keychain and the ssh-agent

The `google_compute_engine` key is passphrase-protected. `keychain` means you
type that passphrase **once per boot**, not once per connection.

`.zprofile` runs `eval $(keychain --eval)` at login. keychain starts an
ssh-agent, or reuses the running one, and records its socket and PID in
`~/.keychain/<hostname>-sh`. Because that outlives the shell, every later login
attaches to the same agent. It dies on reboot, so the first `ssh carbonsteel`
after a restart prompts once and then stays quiet.

The `carbonsteel` block sets `AddKeysToAgent yes`, so the key is loaded into the
agent on first use — no explicit `ssh-add` needed.

Useful commands:

```sh
ssh-add -l                              # what is currently loaded
ssh-add ~/.ssh/google_compute_engine    # load it now, rather than on first ssh
keychain --eval google_compute_engine   # same, but via keychain
ssh-add -D                              # drop all keys (agent keeps running)
```

To have the key loaded at login rather than on first use, change the `.zprofile`
line to name it:

```sh
eval $(keychain --eval google_compute_engine)
```

The tradeoff is that you'll be prompted during login even on days you never
touch the VM.

### Gotchas

**Non-interactive SSH fails if the agent is empty.** `ssh -o BatchMode=yes` and
anything scripted cannot prompt for a passphrase, so they fail with `Permission
denied (publickey)` until the key is loaded. Run `ssh-add -l` first if a script
is failing mysteriously.

**`UseKeychain` does nothing here** and is deliberately absent from the config.
It's an Apple-specific ssh patch, and `$PATH` resolves `ssh` to Homebrew's
upstream build, which ignores it. It also targets macOS's own agent, not
keychain's.

**The agent socket lives under `~/.ssh/agent/`.** On a machine still using the
old whole-directory symlink layout that puts it inside the git tree; the
deny-by-default `.gitignore` covers it.

## Notes on GCE Ubuntu images

They ship *minimized*: `/etc/dpkg/dpkg.cfg.d/excludes` contains
`path-exclude=/usr/share/man/*`, so man pages are discarded as each package
unpacks. Installing `manpages` does nothing visible. Run `sudo unminimize` to
restore them.

Relatedly, `.zprofile` only extends `MANPATH` with directories that exist and
leaves a trailing colon on it. Without that colon, setting `MANPATH` at all
*replaces* the system search path from `/etc/manpath.config` rather than adding
to it, which makes every system man page vanish.
