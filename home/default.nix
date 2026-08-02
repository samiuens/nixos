{
  lib,
  userConfig,
  ...
}:

let
  smiLib = import ../lib { inherit lib; };
in
{
  imports = smiLib.importModulesRecursive ./.;

  options.smi.user = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Current user's declarative options from users/*.nix.";
  };

  config = {
    smi.user = userConfig;

    programs = (userConfig.programs.raw or { }) // {
      home-manager.enable = lib.mkDefault true;
    };

    services = userConfig.services.raw or { };

    _module.args = { inherit userConfig; };
  };
}
