{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.packages.comma;
in
{
  options.smi.packages.comma = {
    enable = lib.mkEnableOption "comma with the prebuilt nix-index database";
  };

  config = lib.mkIf cfg.enable {
    programs.nix-index-database.comma.enable = true;
  };
}
