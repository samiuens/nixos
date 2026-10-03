{
  lib,
  userConfig,
  ...
}:

let
  cfg = userConfig.desktop.macos;

  stamp = "$HOME/.local/state/nix-config/dock-cleared";
  attempts = 10;
in
{
  config = lib.mkIf cfg.clearDockOnFirstLogin {
    smi.loginAgents.clear-dock = ''
      stamp="${stamp}"

      if [ -e "$stamp" ]; then
        exit 0
      fi

      plist="$(/usr/bin/mktemp -t dock)"
      trap '/bin/rm -f "$plist"' EXIT

      pinned() {
        /usr/bin/defaults export com.apple.dock "$plist"
        /usr/bin/plutil -extract persistent-apps raw -o - "$plist" 2>/dev/null || echo 0
      }

      attempt=0

      while [ "$attempt" -lt ${toString attempts} ]; do
        attempt=$((attempt + 1))

        # Writing before the dock is up gets overwritten as it starts.
        if ! /usr/bin/pgrep -x Dock >/dev/null 2>&1; then
          /bin/sleep 2
          continue
        fi

        /usr/bin/defaults write com.apple.dock persistent-apps -array
        /usr/bin/killall Dock || true

        # Mid-restart the preference reads empty either way.
        waited=0

        while [ "$waited" -lt 10 ]; do
          /bin/sleep 1
          waited=$((waited + 1))

          if /usr/bin/pgrep -x Dock >/dev/null 2>&1; then
            break
          fi
        done

        /bin/sleep 2

        if [ "$(pinned)" = "0" ]; then
          /bin/mkdir -p "$(/usr/bin/dirname "$stamp")"
          /usr/bin/touch "$stamp"
          exit 0
        fi
      done
    '';
  };
}
