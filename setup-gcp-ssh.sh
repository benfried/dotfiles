#!/bin/zsh
#
# setup-gcp-ssh.sh — per-machine SSH key setup for GCP VMs.
#
# Idempotent: safe to run repeatedly. Generates this machine's key if absent,
# then registers its public half in each instance's metadata so plain
# `ssh <instance>` works via the IAP tunnel configured in .ssh/config.
#
# Run AFTER `gcloud auth login`. install.sh calls it, but on a fresh machine
# gcloud is usually neither installed nor authenticated yet, in which case this
# exits cleanly and tells you to re-run it later. That is the expected path.
#
# Why this exists rather than just `gcloud compute ssh`: gcloud registers keys
# under your LOCAL username in PROJECT metadata. We log in as a different
# remote user whose keys live in INSTANCE metadata, so gcloud's registration
# does not grant access to the account we actually want.

set -euo pipefail

# name:zone — add a line per VM.
INSTANCES=(
    "carbonsteel:us-central1-c"
)

PROJECT=${GCP_PROJECT:-deal-tools}
REMOTE_USER=${GCP_SSH_USER:-ben}
KEY=${GCP_SSH_KEY:-$HOME/.ssh/google_compute_engine}

info()  { print -r -- "==> $*" }
warn()  { print -r -- "WARNING: $*" >&2 }
die()   { print -r -- "ERROR: $*" >&2; exit 1 }

# ---------------------------------------------------------------- preflight --
# Exit 0, not 1, on a machine that simply is not set up for GCP yet: this runs
# from install.sh and must never fail the whole dotfiles install.

if ! command -v gcloud >/dev/null 2>&1; then
    info "gcloud not installed — skipping GCP SSH setup."
    info "    Install it (brew bundle), run 'gcloud auth login', then re-run this script."
    exit 0
fi

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | grep -q .; then
    info "gcloud is installed but not authenticated — skipping GCP SSH setup."
    info "    Run 'gcloud auth login', then re-run this script."
    exit 0
fi

info "authenticated as $(gcloud auth list --filter=status:ACTIVE --format='value(account)' 2>/dev/null | head -1)"

# --------------------------------------------------------------------- key --
# Ed25519 rather than the RSA that `gcloud compute ssh` hardcodes: shorter,
# faster, and gcloud honours whatever key already exists at this path.

if [[ ! -f $KEY ]]; then
    if [[ ! -t 0 ]]; then
        warn "no key at $KEY and stdin is not a terminal; cannot prompt for a"
        warn "passphrase. Re-run this script from an interactive shell."
        exit 0
    fi
    info "generating $KEY"
    info "    Choose a passphrase. ~/.ssh lives inside the dotfiles git tree, so an"
    info "    unencrypted key is one stray 'cp -r' or backup away from exposure."
    ssh-keygen -t ed25519 -f "$KEY" -C "$(whoami)@$(hostname -s)"
else
    info "using existing key $KEY"
fi

[[ -f ${KEY}.pub ]] || die "missing ${KEY}.pub — delete $KEY and re-run to regenerate the pair"

# git stores no directory modes and only the executable bit on files, so a
# fresh clone yields 755/644 and ssh refuses a group-readable private key.
chmod 700 "$(dirname "$KEY")"
chmod 600 "$KEY"
chmod 644 "${KEY}.pub"

# The key body, field 2 — the comment and type prefix vary, this does not.
KEYBODY=$(awk '{print $2}' "${KEY}.pub")
PUBLINE="${REMOTE_USER}:$(cat "${KEY}.pub")"

# ---------------------------------------------------------------- register --

for entry in "${INSTANCES[@]}"; do
    name=${entry%%:*}
    zone=${entry##*:}

    info "checking ${name} (${zone})"

    if ! existing=$(gcloud compute instances describe "$name" \
            --zone="$zone" --project="$PROJECT" \
            --format="value(metadata.items.ssh-keys)" 2>/dev/null); then
        warn "  cannot describe ${name} — skipping (wrong zone, or no access?)"
        continue
    fi

    if print -r -- "$existing" | grep -qF -- "$KEYBODY"; then
        info "  already registered for ${REMOTE_USER} — nothing to do"
        continue
    fi

    # add-metadata REPLACES the entire ssh-keys value, so we must read, append,
    # and write back the whole thing. Passing only the new key would silently
    # delete every other key on the instance and lock out other machines.
    tmp=$(mktemp -t gcp-ssh-keys) || die "mktemp failed"
    trap 'rm -f "$tmp"' EXIT

    # Drop blank lines: gcloud's value() formatter appends a trailing newline,
    # and a blank entry corrupts the metadata.
    print -r -- "$existing" | grep -v '^[[:space:]]*$' > "$tmp" || true
    before=$(wc -l < "$tmp" | tr -d ' ')
    print -r -- "$PUBLINE" >> "$tmp"

    info "  appending key for ${REMOTE_USER} (${before} existing entr$([[ $before == 1 ]] && print y || print ies) preserved)"
    if gcloud compute instances add-metadata "$name" \
            --zone="$zone" --project="$PROJECT" \
            --metadata-from-file ssh-keys="$tmp" >/dev/null 2>&1; then
        info "  registered"
    else
        warn "  failed to update metadata for ${name}"
    fi

    rm -f "$tmp"
    trap - EXIT
done

# ------------------------------------------------------------- known_hosts --
# Host keys ride along in the committed .ssh/known_hosts, so a fresh clone
# already trusts these instances. Warn rather than fix: silently accepting an
# unverified host key is exactly what known_hosts exists to prevent.

for entry in "${INSTANCES[@]}"; do
    name=${entry%%:*}
    if ! grep -q "^${name}[ ,]" "$HOME/.ssh/known_hosts" 2>/dev/null; then
        warn "no host key for '${name}' in ~/.ssh/known_hosts."
        warn "  First connect will prompt you to accept one blind. To verify it instead,"
        warn "  compare against the instance's recorded key before saying yes:"
        warn "    gcloud compute instances describe ${name} --zone=${entry##*:} --format='value(id)'"
        warn "    grep compute.<that-id> ~/.ssh/google_compute_known_hosts"
    fi
done

info "done — try: ssh ${INSTANCES[1]%%:*}"
