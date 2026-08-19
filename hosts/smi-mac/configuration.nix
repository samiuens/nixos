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
      home-manager.enable = true;

      homebrew.enable = true;

      nix.enable = true;

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
