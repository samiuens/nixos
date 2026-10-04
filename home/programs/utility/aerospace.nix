{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.utility.aerospace or { };

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

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

  # Home Manager always writes start-at-login = false and asserts against it
  # without its launchd agent, so the generated file is replaced instead.
  configFile = tomlFormat.generate "aerospace" (settings // { start-at-login = true; });
in
{
  config = lib.mkMerge [
    (lib.mkIf (isDarwin && (cfg.enable or false)) {
      programs.aerospace = {
        enable = true;
        inherit settings;

        launchd.enable = false;
      };

      home.file.".aerospace.toml".source = lib.mkForce configFile;
    })

    # Removes the agent nix-darwin's services.aerospace left in ~/Library/LaunchAgents.
    # Not gated on `enable`, so turning AeroSpace off removes it too.
    (lib.mkIf isDarwin {
      home.activation.removeNixDarwinAerospaceAgent = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        orphan_agent="$HOME/Library/LaunchAgents/org.nixos.aerospace.plist"

        if [[ -e "$orphan_agent" ]]; then
          run /bin/launchctl bootout "gui/$(id -u)/org.nixos.aerospace" 2>/dev/null || true
          run rm -f "$orphan_agent"
        fi
      '';
    })
  ];
}
