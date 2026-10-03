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
      description = ''
        Whether to switch off the shortcuts macOS handles itself, the ones
        listed under “Keyboard Shortcuts” in System Settings: Mission Control,
        space switching, Dock hiding, Spotlight, screenshots and friends. They
        fire before any application sees the key, so a window manager cannot
        bind over them.

        This covers `com.apple.symbolichotkeys` only. Menu commands such as
        `cmd-q` or `cmd-h` belong to the application rather than to the system
        and are left alone; remap those through
        `system.defaults.NSGlobalDomain.NSUserKeyEquivalents`.
      '';
    };

    ids = lib.mkOption {
      type = lib.types.listOf lib.types.ints.unsigned;
      default = lib.range 0 260;
      description = ''
        Hotkey slots to sweep. macOS identifies each of its built-in shortcuts
        by a number, and a slot that has never been written still fires, so the
        default covers a whole range rather than only the slots already present
        in the preference file. Numbers macOS does not use are simply ignored.

        260 is the highest number System Settings knows about. It reads its own
        list from

        ```
        /System/Library/ExtensionKit/Extensions/KeyboardSettings.appex/Contents/Resources/en.lproj/DefaultShortcutsTable.xml
        ```

        which names every slot, so that file is the place to look when picking
        numbers for `keep`.
      '';
    };

    keep = lib.mkOption {
      type = lib.types.listOf lib.types.ints.unsigned;
      default = [
        32 # Mission Control, named “All windows” in the table
        64 # Show Spotlight search
        65 # Show Finder search window
      ];
      description = ''
        Hotkey slots handed back to macOS. Their entries are removed from the
        preference file rather than skipped, so the shipped shortcut applies
        again and moving a number in here revives a shortcut an earlier sweep
        already switched off.

        The flip side is that these slots are reset at every login, so a
        shortcut named here cannot be reassigned in System Settings and made to
        stick. Drop the number from this list to hand it back to the user.

        Note that one shortcut in System Settings often spans several slots.
        The screenshot group alone is seven of them — ⇧⌘3, ⇧⌘4 and ⇧⌘5 each
        have their own, plus clipboard and Touch Bar variants — so a group has
        to be named in full or dropped in full.
      '';
      example = lib.literalExpression "[ ]";
    };

    batchSize = lib.mkOption {
      type = lib.types.ints.positive;
      default = 6;
      description = ''
        How many hotkey slots to hand `PlistBuddy` per invocation. It crashes
        once it is given more than roughly fourteen commands at once and a slot
        costs up to two of them, so this trades process count against that
        limit and has no other effect.
      '';
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
