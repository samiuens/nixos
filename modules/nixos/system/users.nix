{
  lib,
  config,
  hostName,
  pkgs,
  ...
}:

let
  cfg = config.smi.system.users;
  enabledUsers = lib.filterAttrs (name: _: builtins.elem name cfg.enabledUsers) cfg.users;
  smiLib = import ../../../lib { inherit lib; };

  userModule =
    { name, ... }:
    {
      imports = [ (smiLib.userConfigModule { inherit hostName; }) ];

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

  unavailable = lib.filterAttrs (_: entry: !(smiLib.nixUsable pkgs entry.package)) (
    smiLib.enabledCatalogueEntries pkgs enabledUsers
  );

  userFaces = lib.filterAttrs (_: builtins.pathExists) (
    lib.mapAttrs (name: _: ../../../users + "/${name}/_face.png") enabledUsers
  );

  registerUserFace =
    name: face:
    let
      escapedName = lib.escapeShellArg name;
      escapedFace = lib.escapeShellArg (toString face);
    in
    ''
      user_uid="$(${lib.getExe' pkgs.coreutils "id"} -u -- ${escapedName})"

      case "$user_uid" in
        ""|*[!0-9]*)
          echo "Unable to resolve a numeric UID for ${name}" >&2
          exit 1
          ;;
      esac

      ${lib.getExe' pkgs.systemd "busctl"} call \
        org.freedesktop.Accounts \
        "/org/freedesktop/Accounts/User$user_uid" \
        org.freedesktop.Accounts.User \
        SetIconFile \
        s \
        ${escapedFace}
    '';
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

    enabledUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = builtins.attrNames cfg.users;
      description = "Declarative users enabled on this host, identified by login name.";
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
    ]
    ++ lib.mapAttrsToList (path: entry: {
      assertion = false;
      message = ''
        ${path} has no nixpkgs package available on ${pkgs.stdenv.hostPlatform.system}. It is
        provided by ${
          if entry ? masApp then "the Mac App Store" else ''the Homebrew cask "${entry.cask}"''
        }, which only exists on darwin, so enable it there rather than for every host this user
        is on.
      '';
    }) unavailable;

    users.mutableUsers = cfg.mutableUsers;
    users.users = lib.mapAttrs mkNixosUser enabledUsers;

    systemd.services.accounts-daemon-user-icons =
      lib.mkIf (config.services.accounts-daemon.enable && userFaces != { })
        {
          description = "Register declarative user icons with AccountsService";
          after = [ "accounts-daemon.service" ];
          before = [ "display-manager.service" ];
          requires = [ "accounts-daemon.service" ];
          wantedBy = [ "display-manager.service" ];

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };

          script = lib.concatStringsSep "\n" (lib.mapAttrsToList registerUserFace userFaces);
        };
  };
}
