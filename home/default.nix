{
  lib,
  userConfig,
  ...
}:

let
  smiLib = import ../lib { inherit lib; };
  face = ../users + "/${userConfig.name}/_face.png";
in
{
  imports = smiLib.importModulesRecursive ./.;

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
