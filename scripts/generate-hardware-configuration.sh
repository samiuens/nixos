#!/usr/bin/env bash

set -Eeuo pipefail

readonly FLAKE_ATTR="${FLAKE_ATTR:-${1:-smi-nix}}"
readonly ROOT="${ROOT:-${2:-/}}"

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

if ((EUID != 0)); then
  command -v sudo >/dev/null || die "required command not found: sudo"
  exec sudo \
    --preserve-env=FLAKE_ATTR,ROOT \
    "$0" "$@"
fi

for command in nix nixos-generate-config; do
  command -v "$command" >/dev/null || die "required command not found: $command"
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
readonly REPO_ROOT
readonly HOST_DIR="$REPO_ROOT/hosts/$FLAKE_ATTR"
readonly TARGET="$HOST_DIR/hardware-configuration.nix"
readonly FLAKE="path:$REPO_ROOT"

[[ -f "$HOST_DIR/configuration.nix" ]] || die "unknown host: $FLAKE_ATTR"
[[ -d "$ROOT" ]] || die "root does not exist: $ROOT"

DISKO_CONFIGURED="$(
  nix eval --json \
    "$FLAKE#nixosConfigurations.$FLAKE_ATTR" \
    --apply 'host: (host.options ? disko) && (builtins.attrNames host.config.disko.devices != [ ])'
)"
readonly DISKO_CONFIGURED

generate_args=(--show-hardware-config)

if [[ "$ROOT" != "/" ]]; then
  generate_args+=(--root "$ROOT")
fi

if [[ "$DISKO_CONFIGURED" == "true" ]]; then
  generate_args+=(--no-filesystems)
fi

TEMP_FILE="$(mktemp "$HOST_DIR/.hardware-configuration.nix.XXXXXX")"
readonly TEMP_FILE
trap 'rm -f "$TEMP_FILE"' EXIT

nixos-generate-config "${generate_args[@]}" >"$TEMP_FILE"
chmod 0644 "$TEMP_FILE"
mv -f -- "$TEMP_FILE" "$TARGET"
trap - EXIT

if [[ "$DISKO_CONFIGURED" == "true" ]]; then
  printf 'Generated %s without filesystems (Disko is configured).\n' "$TARGET"
else
  printf 'Generated %s with detected filesystems.\n' "$TARGET"
fi
