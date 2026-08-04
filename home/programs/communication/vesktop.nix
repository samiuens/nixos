{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.communication.vesktop or { };
  vesktop = pkgs.symlinkJoin {
    name = "vesktop-wayland";
    paths = [
      (pkgs.vesktop.override { withSystemVencord = true; })
    ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vesktop --set NIXOS_OZONE_WL 1
    '';
  };
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = [ vesktop ];

    programs.vesktop = {
      enable = true;
      package = null;
    };
  };
}
