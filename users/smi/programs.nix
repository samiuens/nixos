{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  smi.system.users.users.smi.programs = {
    # Only wanted on the mac; the Claude and ChatGPT desktop apps have no
    # nixpkgs package to fall back to anywhere else, so they come from a
    # Homebrew cask.
    ai = lib.mkIf isDarwin {
      chatgpt.enable = true;
      claude.enable = true;
    };

    cad.bambu-studio.enable = lib.mkIf isDarwin true;

    communication.vesktop = {
      enable = true;
      hosts = [ "smi-nix" ];
    };

    # Only wanted on the mac so far; IINA is a macOS-only application.
    media.iina.enable = lib.mkIf isDarwin true;

    # Only wanted on the mac; Office ships for macOS only and has no nixpkgs
    # package to fall back to anywhere else, so it comes from a Homebrew cask.
    office = lib.mkIf isDarwin {
      word.enable = true;
      excel.enable = true;
      #powerpoint.enable = true;
    };

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

      darwinSettings = {
        # Retina panels render the same point size noticeably smaller.
        font-size = 15;

        # macOS 26 hands Ghostty the native glass material. It only has
        # something to blur when the background is not fully opaque, so the
        # opacity below is what makes the effect visible at all.
        background-opacity = 0.9;
        background-blur = "macos-glass-regular";
      };
    };

    sync.nextcloud-client.enable = true;

    utility = lib.mkMerge [
      {
        # Wanted everywhere, unlike the rest of this section: nixpkgs builds it
        # on Linux and darwin takes the cask.
        rpi-imager.enable = true;
      }

      # Only wanted on the mac so far. LinearMouse and Radix have no nixpkgs
      # package to fall back to anywhere else, so they come from a Homebrew
      # cask; the rest are nixpkgs builds.
      (lib.mkIf isDarwin {
        aerospace.enable = true;
        keka.enable = true;
        linearmouse.enable = true;
        monitorcontrol.enable = true;
        pearcleaner.enable = true;
        radix.enable = true;
        raycast.enable = true;
        shottr.enable = true;
        thaw.enable = true;
      })
    ];
  };
}
