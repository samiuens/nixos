{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.communication.vesktop or { };

  inherit (pkgs.stdenv.hostPlatform) isLinux;

  # Vesktop's own Vencord updates faster than nixpkgs when Discord breaks it.
  base = pkgs.vesktop.override { withSystemVencord = false; };

  vesktop =
    if isLinux then
      pkgs.symlinkJoin {
        name = "vesktop-wayland";
        paths = [ base ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/vesktop --set NIXOS_OZONE_WL 1
        '';
      }
    else
      base;
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
