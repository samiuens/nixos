{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.packages.manager;
in
{
  options.smi.packages.manager = {
    enable = lib.mkEnableOption "package manager defaults";

    allowUnfree = lib.mkEnableOption "unfree nixpkgs packages" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = cfg.allowUnfree;
  };
}
