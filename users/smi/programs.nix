{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  smi.system.users.users.smi.programs = {
    ai = lib.mkIf isDarwin {
      chatgpt.enable = true;
      claude.enable = true;
      codexbar.enable = true;
    };

    cad.bambu-studio.enable = lib.mkIf isDarwin true;

    communication.vesktop = {
      enable = true;
      hosts = [ "smi-nix" ];
    };

    education.anki.enable = true;

    media = {
      ente-photos.enable = true;
      iina.enable = lib.mkIf isDarwin true;
    };

    office = lib.mkIf isDarwin {
      word.enable = true;
      excel.enable = true;
      powerpoint.enable = false;
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
        font-size = 16;
        background-opacity = 0.9;
        background-blur = "macos-glass-regular";
      };
    };

    sync.nextcloud-client.enable = true;

    utility = lib.mkMerge [
      # Linux
      {
        rpi-imager.enable = true;
      }

      # Darwin
      (lib.mkIf isDarwin {
        aerospace.enable = true;
        keka.enable = true;
        linearmouse.enable = true;
        #monitorcontrol.enable = true;
        pearcleaner.enable = true;
        radix.enable = true;
        raycast.enable = true;
        #shottr.enable = true;
        thaw.enable = true;
      })
    ];
  };
}
