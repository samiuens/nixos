{ lib }:

{
  nixpkgs,
  hostsDir,
  system ? "x86_64-linux",
  inputModules ? [ ],
  specialArgs ? { },
}:

let
  entries = builtins.readDir hostsDir;

  hostNames = lib.filter (
    name:
    entries.${name} == "directory" && builtins.pathExists (hostsDir + "/${name}/configuration.nix")
  ) (builtins.attrNames entries);

  mkHost =
    name:
    lib.nameValuePair name (
      nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = inputModules ++ [ (hostsDir + "/${name}/configuration.nix") ];
      }
    );
in
builtins.listToAttrs (map mkHost hostNames)
