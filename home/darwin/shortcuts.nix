{
  lib,
  userConfig,
  ...
}:

let
  cfg = userConfig.desktop.macos;

  raycast = userConfig.programs.utility.raycast.enable or false;

  # Mission Control and Finder search; Spotlight only when Raycast is not taking cmd-space.
  keep =
    if cfg.keepShortcuts != null then
      cfg.keepShortcuts
    else
      [
        32
        65
      ]
      ++ lib.optional (!raycast) 64;

  ids = lib.unique (lib.sort (a: b: a < b) (lib.range 0 260 ++ keep));

  # PlistBuddy crashes above ~14 commands per call.
  batchSize = 6;

  idList = lib.concatMapStringsSep " " toString;
in
{
  config = lib.mkIf cfg.disableSystemShortcuts {
    smi.loginAgents.disable-system-shortcuts = ''
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

      keep=" ${idList keep} "

      set --
      batched=0

      for id in ${idList ids}; do
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

        if [ "$batched" -eq ${toString batchSize} ]; then
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
}
