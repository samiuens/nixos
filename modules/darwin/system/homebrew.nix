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
      description = "Whether to adopt an existing Homebrew installation instead of failing.";
    };

    mutableTaps = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether Homebrew may manage its own taps. Pinning taps declaratively requires
        adding the tap repositories as flake inputs, which makes every flake update
        fetch several hundred megabytes of tap history.
      '';
    };

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to update Homebrew itself during activation.";
    };

    upgrade = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to upgrade outdated formulae and casks during activation.";
    };

    cleanup = lib.mkOption {
      type = lib.types.enum [
        "none"
        "uninstall"
        "zap"
      ];
      default = "none";
      description = ''
        What to do with Homebrew packages that this configuration does not declare.
        The default leaves manually installed packages alone; "uninstall" and "zap"
        make the declared set authoritative and will remove anything installed by hand.
      '';
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
      description = ''
        Additional taps required by extraCasks or extraBrews.

        A plain name is marked trusted, because declaring a tap here is the
        decision to trust it: Homebrew 6 refuses to load formulae and casks from
        untrusted third-party taps and aborts activation. Pass nix-darwin's tap
        attribute set instead to say otherwise.
      '';
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
      brews = cfg.extraBrews;
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
      ) cfg.extraTaps;

      onActivation = {
        inherit (cfg) autoUpdate cleanup upgrade;
      };
    };
  };
}
