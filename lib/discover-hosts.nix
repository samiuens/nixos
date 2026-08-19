{ lib }:

hostsDir:

let
  entries = builtins.readDir hostsDir;

  isHost =
    name:
    entries.${name} == "directory" && builtins.pathExists (hostsDir + "/${name}/configuration.nix");

  defaults = {
    platform = "nixos";
    system = "x86_64-linux";
  };

  mkHost =
    name:
    let
      metaPath = hostsDir + "/${name}/meta.nix";
      meta = lib.optionalAttrs (builtins.pathExists metaPath) (import metaPath);
    in
    lib.nameValuePair name (
      defaults
      // meta
      // {
        configuration = hostsDir + "/${name}/configuration.nix";
      }
    );
in
builtins.listToAttrs (map mkHost (lib.filter isHost (builtins.attrNames entries)))
