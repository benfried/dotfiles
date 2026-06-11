# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository using a symlink-based installation approach. The `.dotfiles/` subdirectory contains actual configuration files that get symlinked to `~` by the install script. The root directory contains management scripts and package lists.

## Key Commands

- **Install dotfiles:** `./install.sh` — backs up existing home dotfiles to `~/.dotfiles/<timestamp>/`, copies `lib/` to `~/lib/`, symlinks `.dotfiles/*` to `~`, and clones/updates oh-my-zsh
- **Install MacPorts packages:** `./installports` — installs packages listed in `Ports`
- **Update Ports list:** `./makeports` — regenerates `Ports` from currently installed MacPorts packages

There is no build system, test suite, or linter.

## Architecture

**Directory layout:**
- `.dotfiles/` — config files symlinked to home directory (e.g., `.dotfiles/.emacs` → `~/.emacs`)
- `lib/elisp/` — custom Emacs Lisp libraries (110+ modules, loaded by `.emacs`)
- `Library/` — macOS user Library settings (fonts, preferences, keyboard layouts)
- `quicklisp/` — Common Lisp package manager and packages
- `Ports` / `brews` — package lists for MacPorts and Homebrew

**Platform awareness:**
- `install.sh` conditionally symlinks `.tmux.conf.mac` vs `.tmux.conf.non-mac` based on Darwin detection
- `.gitconfig` uses `includeIf` for macOS-specific git settings (`.gitconfig-macos`)
- `.zprofile` conditionally sets up Homebrew, MacPorts, OrbStack, and keychain paths

**Shell setup chain:** `.zprofile` (env vars, PATH) → `.zshrc` (oh-my-zsh, plugins, completions) with `.envfile` sourced for legacy sh/bash aliases and functions.

**Emacs config** (`.emacs`, 1300+ lines) features extensive Tramp remote connection profiles (SSH, Kubernetes, flatpak) and loads custom org-mode from `~/lib/elisp/org/lisp`.
