{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.desktop.shared.fonts;
in
{
  options.smi.desktop.shared.fonts = {
    enable = lib.mkEnableOption "shared desktop fonts";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.adwaita-fonts
        pkgs.jetbrains-mono
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.inter
        pkgs.montserrat
      ];
      description = "Font packages installed system-wide.";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      inherit (cfg) packages;

      fontconfig.defaultFonts = {
        sansSerif = [ "Adwaita Sans" ];
        monospace = [
          "JetBrains Mono"
          "JetBrainsMono Nerd Font"
        ];
      };
    };
  };
}
