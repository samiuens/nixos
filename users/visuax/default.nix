{ pkgs, ... }:

{
  smi.system.users.users.visuax = {
    description = "visuax";

    packages = with pkgs; [ ];

    desktop.niri = {
      enable = true;
    };
  };
}
