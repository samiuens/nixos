{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.desktop.fonts;
in
{
  options.smi.desktop.fonts = {
    enable = lib.mkEnableOption "system fonts";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [
        pkgs.jetbrains-mono
        pkgs.nerd-fonts.jetbrains-mono
        pkgs.inter
        pkgs.montserrat
      ];
      description = "Font packages installed system-wide.";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = { inherit (cfg) packages; };
  };
}
