{
  lib,
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
    # Registers the shell in /etc/shells; selecting it per user is a manual chsh.
    programs.fish.enable = cfg.defaultShell == "fish";
  };
}
