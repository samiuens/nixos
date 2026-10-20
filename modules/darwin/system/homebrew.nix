{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.system.homebrew;
  usersCfg = config.smi.system.users;
  enabledUsers = lib.filterAttrs (name: _: builtins.elem name usersCfg.enabledUsers) usersCfg.users;

  smiLib = import ../../../lib { inherit lib; };

  wanted = smiLib.enabledCatalogueEntries pkgs enabledUsers;

  fallbackEntries = lib.filterAttrs (path: _: !(smiLib.preferNixPackage pkgs path)) wanted;

  fallbackCasks = lib.mapAttrsToList (_: entry: entry.cask) (
    lib.filterAttrs (_: entry: entry ? cask) fallbackEntries
  );

  fallbackBrews = lib.mapAttrsToList (_: entry: entry.brew) (
    lib.filterAttrs (_: entry: entry ? brew) fallbackEntries
  );

  # A fully qualified `user/repo/name` needs its tap declared, or cleanup would untap it.
  fallbackTaps = lib.unique (
    lib.concatMap (
      name:
      let
        parts = lib.splitString "/" name;
      in
      lib.optional (lib.length parts == 3) "${lib.elemAt parts 0}/${lib.elemAt parts 1}"
    ) (fallbackBrews ++ fallbackCasks)
  );

  fallbackMasApps = lib.listToAttrs (
    lib.mapAttrsToList (_: entry: lib.nameValuePair entry.masApp.name entry.masApp.id) (
      lib.filterAttrs (_: entry: entry ? masApp) fallbackEntries
    )
  );
in
{
  options.smi.system.homebrew = {
    enable = lib.mkEnableOption "Homebrew as a fallback for unsupported nixpkgs packages";

    user = lib.mkOption {
      type = lib.types.str;
      default = config.system.primaryUser;
      description = "User owning the Homebrew prefix.";
    };

    autoMigrate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to adopt an existing Homebrew installation.";
    };

    mutableTaps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether Homebrew may manage its own taps.";
    };

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to update Homebrew itself during activation.";
    };

    upgrade = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to upgrade formulae and casks on activation.";
    };

    cleanup = lib.mkOption {
      type = lib.types.enum [
        "none"
        "uninstall"
        "zap"
      ];
      default = "none";
      description = "How to handle Homebrew packages not declared here.";
    };

    extraCasks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional casks with no nixpkgs counterpart.";
    };

    extraBrews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional formulae with no nixpkgs counterpart.";
    };

    extraTaps = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str lib.types.attrs);
      default = [ ];
      description = "Additional taps; plain names are marked trusted.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.user != null && cfg.user != "";
        message = "smi.system.homebrew.user must be set, either directly or through system.primaryUser.";
      }
    ];

    nix-homebrew = {
      enable = true;
      inherit (cfg) user autoMigrate mutableTaps;
    };

    homebrew = {
      enable = true;
      brews = lib.unique (lib.naturalSort (fallbackBrews ++ cfg.extraBrews));
      casks = lib.unique (lib.naturalSort (fallbackCasks ++ cfg.extraCasks));
      masApps = fallbackMasApps;
      taps = map (
        tap:
        if lib.isString tap then
          {
            name = tap;
            trusted = true;
          }
        else
          tap
      ) (fallbackTaps ++ cfg.extraTaps);

      onActivation = {
        inherit (cfg) autoUpdate cleanup upgrade;
      };
    };
  };
}
