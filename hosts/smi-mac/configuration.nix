{ ... }:

{
  imports = [
    ../../modules/darwin
  ];

  smi = {
    desktop.fonts.enable = true;

    environment.shell.enable = true;

    packages = {
      comma.enable = true;
      manager.enable = true;
    };

    security.sudo.enable = true;

    services = {
      localsend.enable = true;
      netbird.enable = true;
    };

    system = {
      dock.enable = true;

      firewall.enable = true;

      home-manager.enable = true;

      homebrew = {
        enable = true;

        # The declared set is authoritative: anything installed by hand is
        # uninstalled on the next activation.
        cleanup = "uninstall";
      };

      keyboard = {
        enable = true;

        # Spotlight's slot is dropped from the kept list so the sweep switches
        # it off rather than restoring it at every login, which leaves cmd-space
        # free for Raycast.
        keep = [
          32 # Mission Control, named “All windows” in the table
          65 # Show Finder search window
        ];
      };

      nix = {
        enable = true;

        # This host runs a Determinate Nix installation.
        manageNixDaemon = false;
      };

      users = {
        enable = true;
        enabledUsers = [
          "smi"
          "visuax"
        ];
        homeStateVersion = "26.11";
      };
    };
  };

  system = {
    primaryUser = "smi";
    stateVersion = 6;
  };
}
