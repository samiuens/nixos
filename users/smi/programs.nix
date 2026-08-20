{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  smi.system.users.users.smi.programs = {
    communication.vesktop.enable = true;

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

    sync.nextcloud-client.enable = true;

    # Only wanted on the mac so far, and all three come from a Homebrew cask
    # there. Cork and LinearMouse have no nixpkgs package to fall back to
    # anywhere else.
    utility = lib.mkIf isDarwin {
      cork.enable = true;
      dockdoor.enable = true;
      linearmouse.enable = true;
      thaw.enable = true;
    };
  };
}
