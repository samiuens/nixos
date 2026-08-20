{ lib }:

let
  nixUsable = import ./nix-usable.nix { inherit lib; };
in
pkgs: path:
let
  catalogue = import ./app-catalogue.nix pkgs;

  entry = catalogue.${path} or (throw "app-catalogue has no entry for '${path}'");
in
# `preferCask` only means something where Homebrew exists. On Linux the nixpkgs
# package is the only source, so the flag is ignored there.
!(pkgs.stdenv.hostPlatform.isDarwin && (entry.preferCask or false)) && nixUsable pkgs entry.package
