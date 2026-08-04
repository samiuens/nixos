{ pkgs, ... }:

{
  smi.system.users.users.smi = {
    description = "Sami Arda Ünsay";
    permissionLevel = "admin";

    packages = with pkgs; [ ];

    desktop.niri = {
      enable = true;
    };
  };
}
