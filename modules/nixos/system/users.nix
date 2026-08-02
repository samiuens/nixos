{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.system.users;
  smiLib = import ../../../lib { inherit lib; };

  userModule =
    { name, ... }:
    {
      imports = [ smiLib.userConfigModule ];

      options = {
        name = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Login name for this user.";
        };

        description = lib.mkOption {
          type = lib.types.str;
          default = name;
          description = "Human-readable user description.";
        };

        permissionLevel = lib.mkOption {
          type = lib.types.enum [
            "user"
            "admin"
          ];
          default = "user";
          description = "Permission level used to derive system groups.";
        };

        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Additional groups assigned to this user.";
        };

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "System-level packages installed for this user.";
        };

        stateVersion = lib.mkOption {
          type = lib.types.str;
          default = config.system.stateVersion;
          description = "Home Manager state version for this user.";
        };
      };
    };

  mkNixosUser = _: user: {
    inherit (user) description packages;
    isNormalUser = true;

    extraGroups = smiLib.mkUserGroups {
      inherit config;
      inherit (user) permissionLevel extraGroups;
    };
  };
in
{
  imports = smiLib.importModulesRecursive ../../../users;

  options.smi.system.users = {
    enable = lib.mkEnableOption "declarative user management";

    mutableUsers = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether user accounts can be changed outside NixOS configuration.";
    };

    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule userModule);
      default = { };
      description = "Declarative users keyed by login name.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.mutableUsers = cfg.mutableUsers;
    users.users = lib.mapAttrs mkNixosUser cfg.users;
  };
}
