{ ... }:

{
  imports = [
    ../../modules/darwin
  ];

  smi = {
    desktop.fonts.enable = true;

    environment.shell.enable = true;

    packages.manager.enable = true;

    system = {
      dock.enable = true;

      firewall.enable = true;

      home-manager.enable = true;

      homebrew = {
        enable = true;
        extraCasks = [
          "linearmouse"
          "nikitabobko/tap/aerospace"
          "thaw"
        ];

        extraTaps = [ "nikitabobko/tap" ];
      };

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
