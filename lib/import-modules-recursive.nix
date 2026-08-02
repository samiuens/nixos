{ lib }:

dir:
let
  walk =
    isRoot: currentDir:
    let
      entries = builtins.readDir currentDir;

      moduleFiles =
        name:
        let
          path = currentDir + "/${name}";
          type = entries.${name};
        in
        if type == "directory" then
          walk false path
        else if type == "regular" && lib.hasSuffix ".nix" name && !(isRoot && name == "default.nix") then
          [ path ]
        else
          [ ];
    in
    lib.flatten (map moduleFiles (builtins.attrNames entries));
in
walk true dir
