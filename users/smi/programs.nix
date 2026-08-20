{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  smi.system.users.users.smi.programs = {
    communication.vesktop = {
      enable = true;
      hosts = [ "smi-nix" ];
    };

    # Only wanted on the mac so far; IINA is a macOS-only application.
    media.iina.enable = lib.mkIf isDarwin true;

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

    # Only wanted on the mac so far. Cork, DockDoor and LinearMouse have no
    # nixpkgs package to fall back to anywhere else, so they come from a
    # Homebrew cask; the rest are nixpkgs builds.
    utility = lib.mkIf isDarwin {
      cork.enable = true;
      dockdoor.enable = true;
      keka.enable = true;
      linearmouse.enable = true;
      monitorcontrol.enable = true;
      raycast.enable = true;
      shottr.enable = true;
      thaw.enable = true;
    };
  };
}
