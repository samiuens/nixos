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
      description = ''
        Whether to empty the pinned applications out of the dock the first time
        each user logs in. This runs from a login agent rather than from
        activation, because `system.defaults` only ever writes preferences for
        `system.primaryUser` and a freshly created account is handed Apple's
        default dock the first time it reaches the desktop.

        That same hand-out is what the agent races: on a new account it can
        land after the clear, quietly restoring the applications. The clear is
        therefore checked and repeated, and a login that never manages it stays
        unstamped so the next one tries again.
      '';
    };

    attempts = lib.mkOption {
      type = lib.types.ints.positive;
      default = 10;
      description = ''
        How many times a single login may clear the dock and check the result
        before giving up and leaving the job to the next login. Each attempt
        costs a few seconds, all of them on the first login of a new account
        and none of them afterwards.
      '';
    };

    stampFile = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.local/state/nix-config/dock-cleared";
      description = ''
        Marker recording that this user's dock has already been cleared. The
        agent stops at the first login that creates it, so applications pinned
        afterwards survive later logins. Interpreted by the shell, so it may
        refer to `$HOME`.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.clearOnFirstLogin) {
    launchd.agents.clear-dock = {
      # /Library/LaunchAgents, so every account picks this up at login rather
      # than just the primary user.
      serviceConfig = {
        RunAtLoad = true;
        # Sessions without a desktop have no dock to clear.
        LimitLoadToSessionType = "Aqua";
      };

      # PATH is not guaranteed this early in a login session, and none of these
      # come from nixpkgs.
      script = ''
        stamp="${cfg.stampFile}"

        if [ -e "$stamp" ]; then
          exit 0
        fi

        plist="$(/usr/bin/mktemp -t dock)"
        trap '/bin/rm -f "$plist"' EXIT

        # An absent key means an empty dock, which is the state being aimed at.
        pinned() {
          /usr/bin/defaults export com.apple.dock "$plist"
          /usr/bin/plutil -extract persistent-apps raw -o - "$plist" 2>/dev/null || echo 0
        }

        attempt=0

        while [ "$attempt" -lt ${toString cfg.attempts} ]; do
          attempt=$((attempt + 1))

          # Writing before the dock exists only sets the preference it is about
          # to overwrite on its way up.
          if ! /usr/bin/pgrep -x Dock >/dev/null 2>&1; then
            /bin/sleep 2
            continue
          fi

          /usr/bin/defaults write com.apple.dock persistent-apps -array
          /usr/bin/killall Dock || true

          # Mid-restart the preference reads empty whether or not the clear
          # held, so wait for the dock to come back before believing it.
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
