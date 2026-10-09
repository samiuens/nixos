{
  config,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  enabled =
    config.smi.desktop.noctalia.enable && (userConfig.programs.shell.starship.enable or false);
  inputPath = "${config.xdg.configHome}/noctalia/templates/starship.toml";
  outputPath = "${config.xdg.cacheHome}/noctalia/starship.toml";
  tomlFormat = pkgs.formats.toml { };

  generatedPalette = {
    blue = "{{colors.terminal_normal_blue.default.hex}}";
    green = "{{colors.terminal_normal_green.default.hex}}";
    muted = "{{colors.terminal_bright_black.default.hex}}";
    purple = "{{colors.terminal_normal_magenta.default.hex}}";
    red = "{{colors.terminal_normal_red.default.hex}}";
    yellow = "{{colors.terminal_normal_yellow.default.hex}}";
  };

  fallbackPalette = {
    blue = "#7aa2f7";
    green = "#9ece6a";
    muted = "#777777";
    purple = "#bb9af7";
    red = "#f7768e";
    yellow = "#e0af68";
  };

  fallbackSettings = config.programs.starship.settings // {
    palettes = config.programs.starship.settings.palettes // {
      noctalia = fallbackPalette;
    };
  };
  fallback = tomlFormat.generate "starship-noctalia-fallback.toml" fallbackSettings;
in
{
  config = lib.mkIf enabled {
    programs.starship = {
      configPath = inputPath;
      settings = {
        palette = lib.mkForce "noctalia";
        palettes.noctalia = generatedPalette;
      };
    };

    home.sessionVariables.STARSHIP_CONFIG = lib.mkForce outputPath;

    smi.desktop.noctalia.userTemplates.starship = {
      input_path = inputPath;
      output_path = outputPath;
    };

    home.activation.seedNoctaliaStarshipConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      config_file="${outputPath}"
      if [[ ! -e "$config_file" ]]; then
        run install -Dm644 ${fallback} "$config_file"
      fi
    '';
  };
}
