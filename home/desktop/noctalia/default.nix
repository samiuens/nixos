{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = config.smi.desktop.noctalia;
  enabled = userConfig.desktop.niri.enable or false;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.smi.desktop.noctalia = {
    builtinTemplateIds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Noctalia built-in template identifiers enabled by application integrations.";
    };

    userTemplates = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.str);
      default = { };
      description = "Noctalia user templates keyed by application identifier.";
    };
  };

  config = lib.mkIf enabled {
    xdg.configFile."noctalia/config.toml".source = tomlFormat.generate "noctalia-config.toml" {
      theme.templates = {
        enable_builtin_templates = true;
        builtin_ids = lib.unique cfg.builtinTemplateIds;
        user = cfg.userTemplates;
      };
    };
  };
}
