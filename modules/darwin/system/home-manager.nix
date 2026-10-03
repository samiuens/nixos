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
        isDarwin = true;
      })
    ];

    home = {
      inherit (user) stateVersion;
      username = user.name;
      homeDirectory = "${usersCfg.homeBaseDirectory}/${user.name}";
    };
  };
in
{
  options.smi.system.home-manager = {
    enable = lib.mkEnableOption "Home Manager integration";

    useGlobalPkgs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether Home Manager should reuse the system nixpkgs instance.";
    };

    useUserPackages = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether Home Manager should install packages through users.users.<name>.packages.";
    };

    backupFileExtension = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "backup";
      description = "Extension used when Home Manager backs up files it would otherwise overwrite.";
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
      };
      sharedModules = [
        inputs.sops-nix.homeManagerModules.sops
        inputs.zen-browser.homeModules.twilight
      ];
      users = lib.mapAttrs mkHomeManagerUser enabledUsers;
    };
  };
}
