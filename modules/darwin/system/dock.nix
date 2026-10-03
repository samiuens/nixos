{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.system.dock;
in
{
  options.smi.system.dock = {
    enable = lib.mkEnableOption "declarative dock management";

    clearOnFirstLogin = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to empty the dock on each user's first login.";
    };

    attempts = lib.mkOption {
      type = lib.types.ints.positive;
      default = 10;
      description = "Attempts per login to clear the dock.";
    };

    stampFile = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.local/state/nix-config/dock-cleared";
      description = "Marker file recording that the dock was cleared; may use `$HOME`.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.clearOnFirstLogin) {
    launchd.agents.clear-dock = {
      serviceConfig = {
        RunAtLoad = true;
        LimitLoadToSessionType = "Aqua";
      };

      # PATH is not set this early in a login session.
      script = ''
        stamp="${cfg.stampFile}"

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

        while [ "$attempt" -lt ${toString cfg.attempts} ]; do
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
  };
}
