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

## How `~/.ssh` and `~/.config` are handled

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

`~/.config` gets the same treatment for the same reason — it holds live state
for a great many unrelated applications, so it is created as a real directory
and only named files are linked out of the repo. The list is the `for rel in …`
loop in `install.sh`; add to it when you put a new file under `.dotfiles/.config/`.

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

## Remote desktop on carbonsteel

An XFCE session over VNC, reached through an SSH tunnel. From the Mac:

```sh
vnc        # bring the tunnel up if it is down, then open Screen Sharing
vncdown    # drop the tunnel
```

Both are functions in `.envfile`. `vnc` is idempotent — it asks the existing
connection whether it is alive (`ssh -O check`) rather than guessing from
whoever holds port 5901, so running it twice is harmless.

**The tunnel is the only access path, not a convenience.** Xtigervnc binds
`127.0.0.1` and nothing else, so the desktop is unreachable from the network
even with credentials. VNC's own authentication is weak — 8-character passwords,
and a protocol nobody should expose — so none of it is load-bearing here. SSH
carries the session, which is why your viewer's "unencrypted connection" warning
is both correct in general and safe to dismiss for this specific case.

`Host carbonsteel-vnc` in `.ssh/config` is plain `carbonsteel` plus the forward.
It's a separate alias because `ExitOnForwardFailure yes` would otherwise make
every routine `ssh carbonsteel` fail whenever a tunnel was already up.

### Server side

Nothing to start by hand — it's a systemd unit, so the session survives reboots
and outlives every client:

```sh
sudo systemctl status tigervncserver@:1
sudo systemctl restart tigervncserver@:1     # after editing the config below
```

**None of this state is in this repo.** It lives on the VM, which is why it's
written down here:

| Path (on carbonsteel) | What |
|---|---|
| `~/.config/tigervnc/config` | `geometry`, `depth`, `localhost=yes`, `alwaysshared` |
| `~/.config/tigervnc/xstartup` | execs `startxfce4` |
| `~/.config/tigervnc/passwd` | written by `vncpasswd` |
| `/etc/tigervnc/vncserver.users` | `:1=ben` — maps the display to the account |

To rebuild it on a fresh VM:

```sh
sudo apt install -y tigervnc-standalone-server xfce4 xfce4-goodies
mkdir -p ~/.config/tigervnc
vncpasswd                                             # needs a TTY
printf '%s\n' '#!/bin/sh' 'exec startxfce4' > ~/.config/tigervnc/xstartup
chmod +x ~/.config/tigervnc/xstartup
printf '%s\n' geometry=1920x1080 depth=24 localhost=yes alwaysshared \
    > ~/.config/tigervnc/config
echo ':1=ben' | sudo tee -a /etc/tigervnc/vncserver.users
sudo systemctl enable --now tigervncserver@:1
```

Then confirm it is actually private — this is the check that matters, and the
service path is worth verifying separately from a hand-started server:

```sh
ss -tlnp | grep 5901        # must say 127.0.0.1, never 0.0.0.0
```

### Gotchas

**Config lives in `~/.config/tigervnc/`, not `~/.vnc/`.** Every tutorial online
says `~/.vnc`, and this TigerVNC treats that as a legacy directory it migrates
from only if the XDG one doesn't already exist. Since `vncpasswd` creates the
XDG directory on first run, anything you drop in `~/.vnc` afterwards is silently
ignored — `vncpasswd` appears to have done nothing, and your `xstartup` never
runs.

**`config` and `config.pl` are different formats.** The first is `key=value`,
the second is Perl. `config.pl` wins if both exist.

**XFCE logs two harmless errors at startup.** `DPMS extension missing` is
expected on a virtual display — there's no hardware to power down — and
xfdesktop fails to load `xubuntu-wallpaper.png` because that package isn't
installed, giving a plain background. Neither indicates a problem.

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

## Ghostty and terminfo

Ghostty sets `TERM=xterm-ghostty` and ships that terminfo entry only inside its
own app bundle. A host you SSH into therefore doesn't recognise it, and curses
programs fail outright — `tput` errors, `infocmp` reports no match. This is
handled at two levels.

**On the Ghostty side**, `.config/ghostty/config` enables two shell-integration
features that are *off* by default:

```
shell-integration-features = cursor,sudo,title,path,ssh-env,ssh-terminfo
```

`ssh-terminfo` installs Ghostty's terminfo on remote hosts via `infocmp`/`tic`
and caches which hosts have it; `ssh-env` falls back to `xterm-256color` and
propagates `COLORTERM` if that fails. This covers every host you connect to,
including ones that never run `install.sh`. Use `ghostty +ssh-cache` to inspect
or clear the cache.

Note that `shell-integration-features` **replaces** the entire feature set
rather than adding to it, so it must appear exactly once — a second occurrence
silently discards the first, including any defaults you were relying on. Keep it
on one line.

**On the host side**, `install.sh` compiles `terminfo/xterm-ghostty.terminfo`
into `~/.terminfo` when `tic` exists and the entry isn't already known. This
covers what the Ghostty-side integration can't: a `tmux` session that outlives
the ssh which seeded it, a root shell after `sudo -i` (which won't consult your
`~/.terminfo`), `mosh`, or connecting from a different client.

Refresh the committed copy after a Ghostty upgrade:

```sh
infocmp -x xterm-ghostty > terminfo/xterm-ghostty.terminfo
```

For a host that will never get these dotfiles:

```sh
infocmp -x xterm-ghostty | ssh HOST -- tic -x -
```

## `who`, `users`, and the utmp removal

On Ubuntu 25.10 and later `who` and `users` print **nothing and exit 0**, which
looks identical to an idle machine. Nothing is misconfigured. utmp is being
retired for Y2038 safety — `struct utmp` carries a 32-bit `time_t` even on
64-bit systems — so `/run/utmp` is no longer created, systemd is built `-UTMP`,
and current sessions live in logind. `/var/log/wtmp` gave way to wtmpdb
(SQLite, at `/var/log/wtmp.db`) and `lastlog` to lastlog2.

Ubuntu also made `coreutils-from-uutils` the default, and that Rust `who` has
no logind support. The `gnu-coreutils` package does: GNU coreutils built
`--enable-systemd`, installed as `gnuwho`, `gnuusers`, and ~100 other
`gnu`-prefixed binaries alongside uutils rather than replacing it.

`u` in `.envfile` prefers `gnuusers`, then `gusers` (the MacPorts/Homebrew
name), then `users`, and falls back to `w` only when `users` came back empty.
That last step is the point: `users` fails silently, so testing its *output*
rather than its existence is what catches a utmp-less box without
`gnu-coreutils`.

Accuracy differs by source, and none is strictly right:

| Source | Sees | Caveat |
|---|---|---|
| `w -h` | all sessions | includes the VNC desktop |
| `gnuwho` / `gnuusers` | tty sessions | omits `Type=x11`, so no VNC session |
| `loginctl list-sessions` | everything | includes sessions whose leader is dead |
| `who` / `users` (uutils) | nothing | reads the absent utmp |

### The AppArmor override this VM needs

**Machine-local state, not in this repo** — recreate it after a rebuild.

`gnuwho` is confined by the AppArmor profile `who`: the tunable is
`@{coreutil_dirs}=/{bin/,usr/bin/,usr/bin/gnu,usr/lib/cargo/bin/coreutils/}`,
and that `usr/bin/gnu` entry makes the profile match `/usr/bin/gnuwho`. But
`abstractions/wutmp` grants only `/run/systemd/sessions/ r,` — the directory,
note the trailing slash — never the files inside. So `who` enumerates session
IDs, is denied every one, and prints nothing while exiting 0. Same silent
failure as the utmp case, different cause.

The tell is that `/usr/bin/gnuwho` and a byte-identical copy at another path
behave differently: AppArmor confinement is path-based.

```sh
sudo tee /etc/apparmor.d/local/who >/dev/null <<'PROFILE'
/run/systemd/sessions/* r,
/dev/pts/ r,
PROFILE
sudo apparmor_parser -r /etc/apparmor.d/who
```

`local/who` is the extension point the profile already declares via
`include if exists <local/who>`. `/dev/pts/` is needed too, or the TTY column
is silently blank — the profile's comment assumes that lookup goes through
unmediated `O_PATH`+`fstatat`, which holds for the utmp path but not the logind
one. Both rules are read-only on world-readable paths, so they grant the
profile nothing an unconfined process of yours could not already read.

To revert: delete the file and re-run `apparmor_parser -r`. To check for
breakage, count denials around a run:

```sh
sudo dmesg | grep -c 'apparmor="DENIED"'
```

This is an Ubuntu bug worth reporting (`ubuntu-bug apparmor`): the profile was
taught about `gnu`-prefixed binaries, but the abstraction was never updated for
what a logind-aware `who` actually reads. Drop the override once it is fixed
upstream.

## Notes on GCE Ubuntu images

They ship *minimized*: `/etc/dpkg/dpkg.cfg.d/excludes` contains
`path-exclude=/usr/share/man/*`, so man pages are discarded as each package
unpacks. Installing `manpages` does nothing visible. Run `sudo unminimize` to
restore them.

Relatedly, `.zprofile` only extends `MANPATH` with directories that exist and
leaves a trailing colon on it. Without that colon, setting `MANPATH` at all
*replaces* the system search path from `/etc/manpath.config` rather than adding
to it, which makes every system man page vanish.
