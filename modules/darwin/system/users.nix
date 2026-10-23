{
  lib,
  config,
  hostName,
  ...
}:

let
  cfg = config.smi.system.users;
  enabledUsers = lib.filterAttrs (name: _: builtins.elem name cfg.enabledUsers) cfg.users;
  smiLib = import ../../../lib { inherit lib; };

  userModule =
    { name, ... }:
    {
      imports = [
        (smiLib.userConfigModule {
          inherit hostName;
          inherit (cfg) shared;
        })
      ];

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
          description = "Permission level of this user.";
        };

        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "Additional groups assigned to this user. Unused on darwin.";
        };

        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ ];
          description = "System-level packages installed for this user.";
        };

        stateVersion = lib.mkOption {
          type = lib.types.str;
          default = cfg.homeStateVersion;
          description = "Home Manager state version for this user.";
        };
      };
    };

  mkDarwinUser = _: user: {
    inherit (user) description packages;
    home = "${cfg.homeBaseDirectory}/${user.name}";
  };
in
{
  imports = smiLib.importModulesRecursive ../../../users;

  options.smi.system.users = {
    enable = lib.mkEnableOption "declarative user management";

    homeBaseDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/Users";
      description = "Base directory where users' home directories are located.";
    };

    homeStateVersion = lib.mkOption {
      type = lib.types.str;
      default = lib.trivial.release;
      description = "Default Home Manager state version for users on this host.";
    };

    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule userModule);
      default = { };
      description = "Declarative users keyed by login name.";
    };

    shared = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      example = {
        programs.development.opencode.settings.model = "claude-code/claude-sonnet-5-5";
      };
      description = "Options set for every user, in the same shape as a user's; a user's own value wins.";
    };

    enabledUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtins.attrNames cfg.users;
      description = "Users enabled on this host.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = lib.all (name: builtins.hasAttr name cfg.users) cfg.enabledUsers;
        message = "smi.system.users.enabledUsers may only contain users declared in smi.system.users.users.";
      }
      {
        assertion = lib.length cfg.enabledUsers == lib.length (lib.unique cfg.enabledUsers);
        message = "smi.system.users.enabledUsers must not contain duplicate usernames.";
      }
    ];

    # macOS creates the accounts, so users.knownUsers stays unset.
    users.users = lib.mapAttrs mkDarwinUser enabledUsers;
  };
}
