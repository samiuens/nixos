#!/usr/bin/env bash

set -Eeuo pipefail

readonly DISKO_RUNNER="${DISKO_RUNNER:-github:nix-community/disko/latest}"
readonly MOUNT_POINT="/mnt"

if [[ -t 1 && -z ${NO_COLOR:-} ]]; then
  readonly RED=$'\033[31m'
  readonly GREEN=$'\033[32m'
  readonly YELLOW=$'\033[33m'
  readonly BLUE=$'\033[34m'
  readonly BOLD=$'\033[1m'
  readonly RESET=$'\033[0m'
else
  readonly RED=""
  readonly GREEN=""
  readonly YELLOW=""
  readonly BLUE=""
  readonly BOLD=""
  readonly RESET=""
fi

die() {
  printf '%s%sError:%s %s\n' "$BOLD" "$RED" "$RESET" "$*" >&2
  exit 1
}

confirm() {
  local prompt=$1
  local expected=$2
  local answer

  printf '%s%s%s%s\n%s> %s' "$BOLD" "$BLUE" "$prompt" "$RESET" "$BLUE" "$RESET"
  IFS= read -r answer
  [[ "$answer" == "$expected" ]] || die "confirmation did not match"
}

for command in findmnt lsblk nix nixos-install readlink tar; do
  command -v "$command" >/dev/null || die "required command not found: $command"
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
readonly REPO_ROOT

if [[ -z ${FLAKE_ATTR:-} ]]; then
  host_options=()
  for configuration in "$REPO_ROOT"/hosts/*/configuration.nix; do
    [[ -f "$configuration" ]] || continue
    host_options+=("$(basename -- "$(dirname -- "$configuration")")")
  done

  ((${#host_options[@]} > 0)) || die "no hosts found in $REPO_ROOT/hosts"

  FLAKE_ATTR="$(
    printf '%s\n' "${host_options[@]}" |
      nix --extra-experimental-features 'nix-command flakes' shell nixpkgs#fzf --command fzf --prompt='Select host: '
  )" || die "host selection cancelled"
  [[ -n "$FLAKE_ATTR" ]] || die "no host selected"
fi
readonly FLAKE_ATTR
export FLAKE_ATTR

if ((EUID != 0)); then
  exec sudo \
    --preserve-env=DISKO_RUNNER,FLAKE_ATTR \
    "$0" "$@"
fi

[[ -d /sys/firmware/efi ]] || die "the installer was not booted in UEFI mode"

STAGING_ROOT="$(mktemp -d)"
readonly STAGING_ROOT
trap 'rm -rf "$STAGING_ROOT"' EXIT

mkdir -p "$STAGING_ROOT/config"
tar \
  --exclude='.git' \
  --exclude='.direnv' \
  --exclude='result' \
  --exclude='result-*' \
  -C "$REPO_ROOT" \
  -cf - . |
  tar -C "$STAGING_ROOT/config" -xf -

readonly FLAKE_BASE="path:$STAGING_ROOT/config"
readonly FLAKE="$FLAKE_BASE#$FLAKE_ATTR"

printf '\n%s%sValidating the install-ready NixOS configuration...%s\n' "$BOLD" "$BLUE" "$RESET"
TARGET_DISK="$(
  nix --extra-experimental-features 'nix-command flakes' eval --raw \
    "$FLAKE_BASE#nixosConfigurations.$FLAKE_ATTR.config.disko.devices.disk.system.device"
)" || die "Disko is not imported in the NixOS configuration"
readonly TARGET_DISK

[[ -b "$TARGET_DISK" ]] || die "target is not a block device: $TARGET_DISK"

TARGET_REAL="$(readlink -f "$TARGET_DISK")"
readonly TARGET_REAL
ACTUAL_SERIAL="$(lsblk -dn -o SERIAL "$TARGET_REAL" | tr -d '[:space:]')"
readonly ACTUAL_SERIAL
[[ -n "$ACTUAL_SERIAL" ]] || die "could not determine the target disk serial"

if lsblk -nrpo MOUNTPOINTS "$TARGET_REAL" | grep -q '[^[:space:]]'; then
  lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS "$TARGET_REAL"
  die "the target has mounted filesystems or active swap; unmount or swapoff them first"
fi

printf '\n%s%sTarget disk:%s\n' "$BOLD" "$BLUE" "$RESET"
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL,FSTYPE "$TARGET_REAL"

ROOT_FS="$(
  nix --extra-experimental-features 'nix-command flakes' eval --raw \
    "$FLAKE_BASE#nixosConfigurations.$FLAKE_ATTR.config.fileSystems.\"/\".fsType"
)"
readonly ROOT_FS

[[ "$ROOT_FS" == "btrfs" ]] || die "resolved root filesystem is '$ROOT_FS', expected 'btrfs'"

INITIAL_HASH="$(
  nix --extra-experimental-features 'nix-command flakes' eval --json \
    "$FLAKE_BASE#nixosConfigurations.$FLAKE_ATTR.config.users.users.smi.initialHashedPassword"
)"
readonly INITIAL_HASH

if [[ "$INITIAL_HASH" == "null" ]]; then
  printf '\n%s%sWarning:%s user smi has no initialHashedPassword configured.\n' \
    "$BOLD" "$YELLOW" "$RESET" >&2
  confirm "Type INSTALL-LOCKED to continue with no initial login password." "INSTALL-LOCKED"
fi

printf '%sResolved Disko target:%s %s\n' "$BOLD" "$RESET" "$TARGET_DISK"
printf '%sPhysical target:%s      %s -> %s\n' "$BOLD" "$RESET" "$TARGET_DISK" "$TARGET_REAL"

confirm \
  "Type DRY-RUN to build and inspect the installation plan without touching the disk." \
  "DRY-RUN"

disk_command=(
  nix --extra-experimental-features 'nix-command flakes' run "$DISKO_RUNNER" --
  --mode "destroy,format,mount"
  --root-mountpoint "$MOUNT_POINT"
  --flake "$FLAKE"
)

"${disk_command[@]}" --dry-run

printf '\n%s%sThe dry run completed. The next command will erase the entire target disk.%s\n' \
  "$BOLD" "$RED" "$RESET"
lsblk -o NAME,PATH,SIZE,MODEL,SERIAL,FSTYPE "$TARGET_REAL"

confirm \
  "Type ERASE-$ACTUAL_SERIAL to partition, encrypt, and install NixOS." \
  "ERASE-$ACTUAL_SERIAL"

printf '\n%s%sDisko will now ask for the LUKS passphrase twice.%s\n' \
  "$BOLD" "$YELLOW" "$RESET"
"${disk_command[@]}"

mountpoint -q "$MOUNT_POINT" || die "Disko did not mount the target root at $MOUNT_POINT"
mountpoint -q "$MOUNT_POINT/nix" || die "Disko did not mount the target Nix store"

printf '\n%s%sCopying the configuration onto the target...%s\n' \
  "$BOLD" "$BLUE" "$RESET"
mkdir -p "$MOUNT_POINT/etc"
cp -a "$STAGING_ROOT/config" "$MOUNT_POINT/etc/nixos"

readonly INSTALL_FLAKE="path:$MOUNT_POINT/etc/nixos#$FLAKE_ATTR"

printf '\n%s%sInstalling NixOS directly into the target Nix store...%s\n' \
  "$BOLD" "$BLUE" "$RESET"
nixos-install \
  --root "$MOUNT_POINT" \
  --flake "$INSTALL_FLAKE" \
  --no-channel-copy \
  --no-root-password

printf '\n%s%sInstallation completed.%s Reboot and remove the installer media.\n' \
  "$BOLD" "$GREEN" "$RESET"
