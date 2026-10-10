{
  smi.system.users.users.fittedgroup.programs = {
    communication.signal-desktop.enable = true;
    security.bitwarden.enable = true;
    security.cloudflare-warp.enable = true;

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
  };
}
