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

  # An application falls back to Homebrew only when an enabled user asks for it
  # and the catalogue says nixpkgs is not the source here -- either because the
  # package has no darwin build, or because the entry sets `preferCask`. Entries
  # of the first kind return to nixpkgs automatically once support lands upstream.
  fallbackEntries = lib.filterAttrs (path: _: !(smiLib.preferNixPackage pkgs path)) wanted;

  fallbackCasks = lib.mapAttrsToList (_: entry: entry.cask) fallbackEntries;
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
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional taps required by extraCasks or extraBrews.";
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
      taps = cfg.extraTaps;

      onActivation = {
        inherit (cfg) autoUpdate cleanup upgrade;
      };
    };
  };
}
