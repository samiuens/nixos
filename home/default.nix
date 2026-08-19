{
  lib,
  userConfig,
  isDarwin ? false,
  ...
}:

let
  smiLib = import ../lib { inherit lib; };
  face = ../users + "/${userConfig.name}/_face.png";

  # Modules that cannot be imported at all on darwin: home/desktop reads NixOS-only
  # osConfig options and the niriDisplayManager special arg, and services/flatpak.nix
  # defines options that only exist once the Linux-only nix-flatpak module is loaded.
  linuxOnlyModules = [
    ./desktop
    ./services/flatpak.nix
  ];

  isLinuxOnly =
    path: lib.any (prefix: lib.hasPrefix (toString prefix) (toString path)) linuxOnlyModules;

  modules = lib.filter (path: !(isDarwin && isLinuxOnly path)) (smiLib.importModulesRecursive ./.);
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

    home.file = lib.optionalAttrs (builtins.pathExists face) {
      ".face".source = face;
    };

    programs = (userConfig.programs.raw or { }) // {
      home-manager.enable = lib.mkDefault true;
    };

    services = userConfig.services.raw or { };

    _module.args = { inherit userConfig; };
  };
}
