{
  lib,
  config,
  inputs,
  ...
}:

let
  cfg = config.smi.system.nix;
in
{
  options.smi.system.nix = {
    enable = lib.mkEnableOption "opinionated Nix settings";

    manageNixDaemon = lib.mkEnableOption "nix-darwin management of the Nix installation" // {
      default = true;
      description = "Whether nix-darwin manages Nix; turn off for a Determinate installation.";
    };

    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "root"
        "@admin"
      ];
      description = "Users and groups trusted by the Nix daemon.";
    };

    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "https://nix-community.cachix.org" ];
      description = "Binary caches used by Nix.";
    };

    trustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      description = "Trusted public keys for configured binary caches.";
    };

    gc = {
      enable = lib.mkEnableOption "automatic Nix garbage collection" // {
        default = true;
      };

      interval = lib.mkOption {
        type = lib.types.attrsOf lib.types.int;
        default = {
          Weekday = 7;
          Hour = 3;
          Minute = 15;
        };
        description = "launchd interval for Nix garbage collection.";
      };

      options = lib.mkOption {
        type = lib.types.str;
        default = "--delete-older-than 14d";
        description = "Options passed to nix-collect-garbage.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.nix4vscode.overlays.default ];

    nix = {
      enable = cfg.manageNixDaemon;

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        inherit (cfg) substituters;
        trusted-users = cfg.trustedUsers;
        trusted-public-keys = cfg.trustedPublicKeys;
      };

      # Determinate collects garbage itself, and nix-darwin asserts gc needs nix.enable.
      gc = {
        automatic = cfg.gc.enable && cfg.manageNixDaemon;
        inherit (cfg.gc) interval options;
      };
    };
  };
}
