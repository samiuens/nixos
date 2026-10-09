{
  lib,
  config,
  hostName,
  inputs,
  ...
}:

let
  cfg = config.smi.system.home-manager;
  usersCfg = config.smi.system.users;
  enabledUsers = lib.filterAttrs (name: _: builtins.elem name usersCfg.enabledUsers) usersCfg.users;

  mkHomeManagerUser = _: user: {
    imports = [
      (import ../../../home {
        inherit lib;
        userConfig = user;
      })
    ];

    home = {
      inherit (user) stateVersion;
      username = user.name;
      homeDirectory = "${cfg.homeBaseDirectory}/${user.name}";
    };

  };
in
{
  options.smi.system.home-manager = {
    enable = lib.mkEnableOption "Home Manager integration";

    homeBaseDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home";
      description = "Base directory for home directories.";
    };

    useGlobalPkgs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether Home Manager reuses the system nixpkgs.";
    };

    useUserPackages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether Home Manager installs into users.users.<name>.packages.";
    };

    backupFileExtension = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "backup";
      description = "Extension for files Home Manager backs up.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = usersCfg.enable;
        message = "smi.system.home-manager requires smi.system.users.enable.";
      }
    ];

    home-manager = {
      inherit (cfg) useGlobalPkgs useUserPackages backupFileExtension;
      extraSpecialArgs = {
        inherit hostName inputs;
        niriDisplayManager = config.smi.desktop.niri.displayManager;
        niriShell = config.smi.desktop.niri.shell;
      };
      sharedModules = [
        inputs.nix-flatpak.homeManagerModules.nix-flatpak
        inputs.sops-nix.homeManagerModules.sops
        inputs.zen-browser.homeModules.twilight
        { services.flatpak.enable = lib.mkDefault false; }
      ];
      users = lib.mapAttrs mkHomeManagerUser enabledUsers;
    };
  };
}
