{ lib }:

{
  importModulesRecursive = import ./import-modules-recursive.nix { inherit lib; };
  mkNixosConfigurations = import ./mk-nixos-configurations.nix { inherit lib; };
}
