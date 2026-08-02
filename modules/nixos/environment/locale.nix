{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.environment.locale;
in
{
  options.smi.environment.locale = {
    enable = lib.mkEnableOption "locale configuration";

    defaultLocale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "Default system locale.";
    };

    extraLocaleSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };
      description = "Additional locale category settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    i18n = {
      inherit (cfg) defaultLocale extraLocaleSettings;
    };
  };
}
