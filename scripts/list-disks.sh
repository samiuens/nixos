#!/usr/bin/env bash

set -Eeuo pipefail

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

for command in lsblk readlink tr; do
  command -v "$command" >/dev/null || die "required command not found: $command"
done

printf 'Disks:\n\n'
lsblk --nodeps --output PATH,SIZE,MODEL,SERIAL,TRAN,TYPE

printf '\nCopyable persistent paths:\n\n'

shopt -s nullglob
by_id_paths=(/dev/disk/by-id/*)
found=false

for by_id_path in "${by_id_paths[@]}"; do
  [[ -L "$by_id_path" ]] || continue

  device="$(readlink -f -- "$by_id_path")"
  [[ -b "$device" ]] || continue
  [[ "$(lsblk --noheadings --nodeps --output TYPE -- "$device" | tr -d '[:space:]')" == "disk" ]] || continue

  printf '%s -> %s\n' "$by_id_path" "$device"
  found=true
done

[[ "$found" == "true" ]] || printf 'No /dev/disk/by-id paths found for whole disks.\n'
