{ lib }:

{
  importModulesRecursive = import ./import-modules-recursive.nix { inherit lib; };
}
