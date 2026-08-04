{ pkgs, ... }:

{
  smi.system.users.users.fittedgroup = {
    description = "fit[ted].group";

    packages = with pkgs; [ ];

    desktop.niri = {
      enable = true;
    };
  };
}
