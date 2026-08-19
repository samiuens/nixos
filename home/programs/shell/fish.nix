{
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.shell.fish or { };

  plugin = name: package: {
    inherit name;
    inherit (package) src;
  };

  enabled = name: cfg.plugins.${name}.enable or false;

  inherit (pkgs.stdenv.hostPlatform) isLinux;
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.fish = {
      enable = true;
      plugins =
        lib.optional (enabled "autopair") (plugin "autopair" pkgs.fishPlugins.autopair)
        ++ lib.optional (enabled "bang-bang") (plugin "bang-bang" pkgs.fishPlugins.bang-bang)
        ++ lib.optional (enabled "done") (plugin "done" pkgs.fishPlugins.done)
        ++ lib.optional (enabled "fzf") (plugin "fzf" pkgs.fishPlugins.fzf-fish)
        ++ lib.optional (enabled "sponge") (plugin "sponge" pkgs.fishPlugins.sponge);
    }
    // lib.optionalAttrs ((cfg.interactiveShellInit or "") != "") {
      inherit (cfg) interactiveShellInit;
    };

    home.packages =
      lib.optionals (enabled "fzf") [
        pkgs.bat
        pkgs.fd
        pkgs.fzf
      ]
      # The done plugin notifies through libnotify on Linux and osascript on darwin.
      ++ lib.optional (enabled "done" && isLinux) pkgs.libnotify;
  };
}
