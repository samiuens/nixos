{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.utility.aerospace or { };

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  # Shared baseline, layered under the user's `settings` so a user restates only
  # the keys they want changed rather than the whole window manager.
  baseSettings = {
    config-version = 2;

    after-startup-command = [ "layout tiles" ];

    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;

    accordion-padding = 30;

    default-root-container-layout = "tiles";
    default-root-container-orientation = "auto";

    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];

    automatically-unhide-macos-hidden-apps = true;

    persistent-workspaces = [
      "1"
      "2"
      "3"
      "4"
      "5"
      "6"
      "7"
      "8"
      "9"
    ];

    on-mode-changed = [ ];

    # iOS Simulator (fixed aspect ratio) should float instead of being tiled
    on-window-detected = [
      {
        "if".app-id = "com.apple.iphonesimulator";
        run = [ "layout floating" ];
      }
    ];

    key-mapping.preset = "qwerty";

    gaps = {
      inner.horizontal = 15;
      inner.vertical = 15;
      outer = {
        left = 10;
        bottom = 10;
        top = 10;
        right = 10;
      };
    };

    mode.main.binding = {
      "cmd-h" = "focus left";
      "cmd-j" = "focus down";
      "cmd-k" = "focus up";
      "cmd-l" = "focus right";

      "cmd-shift-h" = "move left";
      "cmd-shift-j" = "move down";
      "cmd-shift-k" = "move up";
      "cmd-shift-l" = "move right";

      "cmd-shift-minus" = "resize smart -50";
      "cmd-shift-equal" = "resize smart +50";

      "shift-cmd-1" = "workspace 1";
      "shift-cmd-2" = "workspace 2";
      "shift-cmd-3" = "workspace 3";
      "shift-cmd-4" = "workspace 4";
      "shift-cmd-5" = "workspace 5";
      "shift-cmd-6" = "workspace 6";
      "shift-cmd-7" = "workspace 7";
      "shift-cmd-8" = "workspace 8";
      "shift-cmd-9" = "workspace 9";

      "shift-alt-cmd-1" = [
        "move-node-to-workspace 1"
        "workspace 1"
      ];
      "shift-alt-cmd-2" = [
        "move-node-to-workspace 2"
        "workspace 2"
      ];
      "shift-alt-cmd-3" = [
        "move-node-to-workspace 3"
        "workspace 3"
      ];
      "shift-alt-cmd-4" = [
        "move-node-to-workspace 4"
        "workspace 4"
      ];
      "shift-alt-cmd-5" = [
        "move-node-to-workspace 5"
        "workspace 5"
      ];
      "shift-alt-cmd-6" = [
        "move-node-to-workspace 6"
        "workspace 6"
      ];
      "shift-alt-cmd-7" = [
        "move-node-to-workspace 7"
        "workspace 7"
      ];
      "shift-alt-cmd-8" = [
        "move-node-to-workspace 8"
        "workspace 8"
      ];
      "shift-alt-cmd-9" = [
        "move-node-to-workspace 9"
        "workspace 9"
      ];
    };
  };

  settings = lib.recursiveUpdate baseSettings (cfg.settings or { });

  tomlFormat = pkgs.formats.toml { };

  # AeroSpace starts itself, through the `start-at-login` its own configuration
  # already understands, rather than through a launchd agent.
  #
  # The generated file has to be replaced rather than configured, because Home
  # Manager writes that key out as `false` unconditionally — a plain `//` over
  # `settings`, not something `launchd.enable` gates. It is kept out of
  # `settings` for the same reason: Home Manager asserts against `start-at-login`
  # unless its own launchd agent is the thing doing the starting.
  configFile = tomlFormat.generate "aerospace" (settings // { start-at-login = true; });
in
{
  config = lib.mkMerge [
    # Home Manager's AeroSpace module asserts it is running on darwin, so the
    # platform check belongs here rather than in every user's file.
    (lib.mkIf (isDarwin && (cfg.enable or false)) {
      programs.aerospace = {
        enable = true;
        inherit settings;

        # No launchd agent: AeroSpace registers itself as a login item instead,
        # so the two cannot both start it.
        launchd.enable = false;
      };

      home.file.".aerospace.toml".source = lib.mkForce configFile;
    })

    # nix-darwin's `services.aerospace` wrote its launchd agent straight into
    # ~/Library/LaunchAgents rather than into the system generation, so dropping
    # that module left the plist behind on every account that had activated it:
    # still loaded, still starting a second AeroSpace to fight this one over the
    # same windows. No generation refers to the file, so nothing will ever
    # collect it and each account has to clear its own copy.
    #
    # Deliberately not gated on `enable`. Turning AeroSpace off should take the
    # stray agent with it, rather than leaving it as the only copy running.
    (lib.mkIf isDarwin {
      home.activation.removeNixDarwinAerospaceAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        orphan_agent="$HOME/Library/LaunchAgents/org.nixos.aerospace.plist"

        if [[ -e "$orphan_agent" ]]; then
          # Fails when the account is not logged in and so has no GUI domain,
          # which is fine: removing the plist stops it coming back either way.
          run /bin/launchctl bootout "gui/$(id -u)/org.nixos.aerospace" 2>/dev/null || true
          run rm -f "$orphan_agent"
        fi
      '';
    })
  ];
}
