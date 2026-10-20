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

    trustedUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "root"
        "@wheel"
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

      dates = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "Systemd calendar for Nix garbage collection.";
      };

      options = lib.mkOption {
        type = lib.types.str;
        default = "--delete-older-than 14d";
        description = "Options passed to nix-collect-garbage.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      inputs.nix4vscode.overlays.default

      # OpenChamber needs OpenCode 2.x, so take the CLI it pins over nixpkgs' 1.x.
      (final: _prev: {
        inherit (inputs.openchamber.packages.${final.stdenv.hostPlatform.system}) opencode-cli;
      })
    ];

    nix = {
      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;
        inherit (cfg) substituters;
        trusted-users = cfg.trustedUsers;
        trusted-public-keys = cfg.trustedPublicKeys;
      };

      gc = {
        automatic = cfg.gc.enable && !config.smi.packages.nh.enable;
        inherit (cfg.gc) dates options;
      };
    };
  };
}
