{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.environment.shell;
in
{
  options.smi.environment.shell = {
    enable = lib.mkEnableOption "shell configuration";

    defaultShell = lib.mkOption {
      type = lib.types.enum [ "fish" ];
      default = "fish";
      description = "Default shell configured by this module.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.fish.enable = cfg.defaultShell == "fish";
    users.defaultUserShell = lib.mkIf (cfg.defaultShell == "fish") pkgs.fish;
  };
}
