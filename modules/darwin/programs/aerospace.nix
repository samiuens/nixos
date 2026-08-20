{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.smi.programs.aerospace;

  tomlFormat = pkgs.formats.toml { };
in
{
  options.smi.programs.aerospace = {
    enable = lib.mkEnableOption "the AeroSpace tiling window manager";

    package = lib.mkPackageOption pkgs "aerospace" { };

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = { };
      description = ''
        AeroSpace configuration, generated into a TOML file the launchd agent
        passes to AeroSpace. See
        <https://nikitabobko.github.io/AeroSpace/guide#configuring-aerospace>
        for the supported keys.

        `start-at-login` and `after-login-command` must stay unset: the agent
        starts AeroSpace at login and keeps it alive, so AeroSpace registering
        itself as a login item on top of that would run a second copy.
      '';
      example = lib.literalExpression ''
        {
          gaps.outer.top = 10;
          mode.main.binding.cmd-h = "focus left";
        }
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.aerospace = {
      enable = true;
      inherit (cfg) package settings;
    };
  };
}
