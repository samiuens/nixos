{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  smi.system.users.users.smi.programs = {
    communication.vesktop.enable = true;

    network.netbird.enable = lib.mkIf isDarwin true;

    security = {
      bitwarden.enable = true;
      keepassxc.enable = true;
      gnupg.enable = true;
      sops.enable = true;
      yubico-authenticator.enable = true;
      yubikey-manager.enable = true;
    };

    terminal.ghostty = {
      enable = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;

        window-padding-x = 10;
        window-padding-y = 10;
        window-padding-balance = true;
        gtk-titlebar = false;
      };

      # Retina panels render the same point size noticeably smaller.
      darwinSettings.font-size = 15;
    };

    sync = {
      localsend.enable = lib.mkIf isDarwin true;
      nextcloud-client.enable = true;
    };

    # Only wanted on the mac so far. Both come from a Homebrew cask there, and
    # LinearMouse has no nixpkgs package to fall back to anywhere else.
    utility = lib.mkIf isDarwin {
      linearmouse.enable = true;
      thaw.enable = true;
    };
  };
}
