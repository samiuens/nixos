{
  config,
  lib,
  pkgs,
  ...
}:

let
  agents = config.smi.loginAgents;
  agentsDir = "${config.home.homeDirectory}/Library/LaunchAgents";

  label = name: "nix-config.${name}";

  plist =
    name: script:
    pkgs.writeText "${label name}.plist" (
      lib.generators.toPlist { escape = true; } {
        Label = label name;
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/wait4path /nix/store && exec ${pkgs.writeShellScript name script}"
        ];
        RunAtLoad = true;
        LimitLoadToSessionType = "Aqua";
      }
    );

  labels = lib.concatMapStringsSep " " label (lib.attrNames agents);
in
{
  options.smi.loginAgents = lib.mkOption {
    type = lib.types.attrsOf lib.types.lines;
    default = { };
    description = "Scripts run at each login of this user.";
  };

  # Home Manager's launchd.agents fails activation for users who are not logged in.
  config.home.activation.loginAgents = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    loggedIn=0
    if /bin/launchctl print "gui/$UID" >/dev/null 2>&1; then
      loggedIn=1
    fi

    for path in ${agentsDir}/nix-config.*.plist; do
      [ -e "$path" ] || continue
      agentLabel="$(basename "$path" .plist)"

      case " ${labels} " in
        *" $agentLabel "*) ;;
        *)
          if [ "$loggedIn" = 1 ]; then
            run /bin/launchctl bootout "gui/$UID/$agentLabel" 2>/dev/null || true
          fi
          run rm -f "$path"
          ;;
      esac
    done

    ${lib.concatStrings (
      lib.mapAttrsToList (name: script: ''
        dst=${agentsDir}/${label name}.plist

        if ! cmp -s ${plist name script} "$dst"; then
          run mkdir -p ${agentsDir}
          run install -m 444 ${plist name script} "$dst"

          if [ "$loggedIn" = 1 ]; then
            run /bin/launchctl bootout "gui/$UID/${label name}" 2>/dev/null || true
            run /bin/launchctl bootstrap "gui/$UID" "$dst" \
              || warnEcho "Could not start ${label name}; it runs at the next login."
          fi
        fi
      '') agents
    )}
  '';
}
