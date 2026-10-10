{
  config,
  lib,
  pkgs,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  usersCfg = config.smi.system.users;
  enabledUsers = lib.filterAttrs (name: _: builtins.elem name usersCfg.enabledUsers) usersCfg.users;

  # The daemon is system-wide, so any user enabling the client turns it on.
  wanted = lib.any (user: user.programs.security.cloudflare-warp.enable or false) (
    lib.attrValues enabledUsers
  );
in
{
  config = lib.mkIf wanted {
    services.cloudflare-warp = {
      enable = true;
      package = (smiLib.appCatalogue pkgs)."programs.security.cloudflare-warp".package;
    };
  };
}
