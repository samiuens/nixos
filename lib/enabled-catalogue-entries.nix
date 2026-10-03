{ lib }:

pkgs: enabledUsers:
let
  catalogue = import ./app-catalogue.nix pkgs;

  userWants = path: user: lib.attrByPath (lib.splitString "." path ++ [ "enable" ]) false user;

  anyUserWants = path: lib.any (userWants path) (lib.attrValues enabledUsers);
in
lib.filterAttrs (path: _: anyUserWants path) catalogue
