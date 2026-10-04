{
  lib,
  userConfig,
  isDarwin ? false,
  ...
}:

let
  smiLib = import ../lib { inherit lib; };
  face = ../users + "/${userConfig.name}/_face.png";

  linuxOnlyModules = [
    ./desktop
    ./services
    ./xdg.nix
  ];

  darwinOnlyModules = [
    ./darwin
  ];

  isUnder =
    prefixes: path: lib.any (prefix: lib.hasPrefix (toString prefix) (toString path)) prefixes;

  modules = lib.filter (
    path: if isDarwin then !(isUnder linuxOnlyModules path) else !(isUnder darwinOnlyModules path)
  ) (smiLib.importModulesRecursive ./.);
in
{
  imports = modules;

  options.smi.user = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Current user's declarative options from users/.";
  };

  config = {
    smi.user = userConfig;

    home.file = lib.optionalAttrs (!isDarwin && builtins.pathExists face) {
      ".face".source = face;
    };

    programs = (userConfig.programs.raw or { }) // {
      home-manager.enable = lib.mkDefault true;
    };

    services = userConfig.services.raw or { };

    _module.args = { inherit userConfig; };
  };
}
