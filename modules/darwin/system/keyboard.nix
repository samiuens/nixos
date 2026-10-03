{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.system.keyboard;

  sweep = lib.unique (lib.sort (a: b: a < b) (cfg.ids ++ cfg.keep));

  idList = lib.concatMapStringsSep " " toString;

  label = config.launchd.agents.disable-system-shortcuts.serviceConfig.Label;
in
{
  options.smi.system.keyboard = {
    enable = lib.mkEnableOption "declarative macOS keyboard shortcut management";

    disableSystemShortcuts = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to switch off the macOS system keyboard shortcuts.";
    };

    ids = lib.mkOption {
      type = lib.types.listOf lib.types.ints.unsigned;
      default = lib.range 0 260;
      description = "Hotkey slots to sweep.";
    };

    keep = lib.mkOption {
      type = lib.types.listOf lib.types.ints.unsigned;
      default = [
        32 # Mission Control, named “All windows” in the table
        64 # Show Spotlight search
        65 # Show Finder search window
      ];
      description = "Hotkey slots reset to their macOS defaults at every login.";
      example = lib.literalExpression "[ ]";
    };

    batchSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 6;
      description = "Hotkey slots per PlistBuddy call; it crashes above ~14 commands.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.disableSystemShortcuts) {
    # The launchd reload runs in root's domain, so re-bootstrap the console user's agent.
    system.activationScripts.postActivation.text = ''
      consoleUser="$(/usr/bin/stat -f %u /dev/console)"

      if [ -n "$consoleUser" ] && [ "$consoleUser" != "0" ]; then
        echo "reloading ${label} for the console session..." >&2
        launchctl bootout "gui/$consoleUser/${label}" 2>/dev/null || true
        launchctl bootstrap "gui/$consoleUser" "/Library/LaunchAgents/${label}.plist" || true
      fi
    '';

    launchd.agents.disable-system-shortcuts = {
      serviceConfig = {
        RunAtLoad = true;
        LimitLoadToSessionType = "Aqua";
      };

      # PATH is not set this early in a login session.
      script = ''
        plist="$(/usr/bin/mktemp -t symbolichotkeys)"
        trap '/bin/rm -f "$plist"' EXIT

        # Edit a copy: cfprefsd owns the live file and discards writes behind its back.
        /usr/bin/defaults export com.apple.symbolichotkeys "$plist"
        /usr/libexec/PlistBuddy -c "Add :AppleSymbolicHotKeys dict" -c "Save" "$plist" >/dev/null 2>&1 || true

        present=" $(/usr/libexec/PlistBuddy -c "Print :AppleSymbolicHotKeys" "$plist" \
          | /usr/bin/sed -n 's/^ *\([0-9][0-9]*\) = Dict {$/\1/p' \
          | /usr/bin/tr '\n' ' ')"

        apply() {
          /usr/libexec/PlistBuddy "$@" -c "Save" "$plist" >/dev/null 2>&1 || true
        }

        keep=" ${idList cfg.keep} "

        set --
        batched=0

        for id in ${idList sweep}; do
          case "$keep" in
            *" $id "*)
              # Removing the slot restores the stock shortcut.
              case "$present" in
                *" $id "*)
                  set -- "$@" -c "Delete :AppleSymbolicHotKeys:$id"
                  ;;
              esac
              ;;
            *)
              case "$present" in
                *" $id "*)
                  set -- "$@" -c "Set :AppleSymbolicHotKeys:$id:enabled false"
                  ;;
                *)
                  set -- "$@" \
                    -c "Add :AppleSymbolicHotKeys:$id dict" \
                    -c "Add :AppleSymbolicHotKeys:$id:enabled bool false"
                  ;;
              esac
              ;;
          esac

          batched=$((batched + 1))

          if [ "$batched" -eq ${toString cfg.batchSize} ]; then
            apply "$@"
            set --
            batched=0
          fi
        done

        if [ "$batched" -gt 0 ]; then
          apply "$@"
        fi

        /usr/bin/defaults import com.apple.symbolichotkeys "$plist"

        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
      '';
    };
  };
}
