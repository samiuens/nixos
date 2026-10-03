{ lib }:

let
  nixUsable = import ./nix-usable.nix { inherit lib; };
in
pkgs: path:
let
  catalogue = import ./app-catalogue.nix pkgs;

  entry = catalogue.${path} or (throw "app-catalogue has no entry for '${path}'");
in
!(pkgs.stdenv.hostPlatform.isDarwin && (entry.preferCask or false)) && nixUsable pkgs entry.package
