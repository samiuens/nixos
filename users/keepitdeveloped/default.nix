{ pkgs, ... }:

{
  smi.system.users.users.keepitdeveloped = {
    description = "{ keep it developed }";

    packages = with pkgs; [ ];

    desktop.niri = {
      enable = true;
      noctalia.plugins = [ "alexander/screen-toolkit" ];
    };
  };
}
