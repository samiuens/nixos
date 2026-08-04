{
  config,
  lib,
  osConfig,
  userConfig,
  ...
}:

let
  cfg = userConfig.desktop.niri or { };
  cursor = osConfig.smi.desktop.niri.cursor;
in
{
  options.smi.desktop.niri.extraConfig = lib.mkOption {
    type = lib.types.lines;
    default = "";
    description = "Additional Niri configuration contributed by desktop integrations.";
  };

  config = lib.mkIf (cfg.enable or false) {
    home.pointerCursor = {
      enable = true;
      inherit (cursor) package name size;
      gtk.enable = true;
      x11.enable = true;
    };

    xdg.configFile."niri/config.kdl".text = ''
      ${builtins.readFile ./niri/config.kdl}

      cursor {
          xcursor-theme "${cursor.name}"
          xcursor-size ${toString cursor.size}
      }

      ${config.smi.desktop.niri.extraConfig}
    '';
  };
}
