{ ... }:

{
  imports = [
    ../../modules/darwin
  ];

  smi = {
    desktop.fonts.enable = true;

    environment.shell.enable = true;

    packages.manager.enable = true;

    programs.aerospace = {
      enable = true;

      settings = {
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
    };

    system = {
      dock.enable = true;

      firewall.enable = true;

      home-manager.enable = true;

      homebrew = {
        enable = true;
        extraCasks = [
          "linearmouse"
          "thaw"
        ];
      };

      keyboard.enable = true;

      nix = {
        enable = true;

        # This host runs a Determinate Nix installation.
        manageNixDaemon = false;
      };

      users = {
        enable = true;
        enabledUsers = [ "smi" ];
        homeStateVersion = "26.11";
      };
    };
  };

  system = {
    primaryUser = "smi";
    stateVersion = 6;
  };
}
