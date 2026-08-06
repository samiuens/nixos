{
  smi.system.users.users.smi.programs = {
    communication.vesktop.enable = true;
    security = {
      bitwarden.enable = true;
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
    };

    sync.nextcloud-client.enable = true;
  };
}
