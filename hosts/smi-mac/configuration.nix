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
      tailscale.enable = true;
    };

    system = {
      dock.enable = true;

      firewall.enable = true;

      home-manager.enable = true;

      homebrew = {
        enable = true;

        cleanup = "uninstall";
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
