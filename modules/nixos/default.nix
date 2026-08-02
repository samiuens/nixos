{ lib, ... }:

let
  smiLib = import ../../lib { inherit lib; };
in
{
  imports = smiLib.importModulesRecursive ./.;
}
