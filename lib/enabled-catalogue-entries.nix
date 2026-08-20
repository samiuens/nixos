{ lib }:

# Catalogue entries that an enabled user has asked for, keyed by option path.
# The Homebrew fallback on darwin and the availability check on Linux both work
# from this set, so the two can never disagree about which applications a host
# is expected to provide.
pkgs: enabledUsers:
let
  catalogue = import ./app-catalogue.nix pkgs;

  userWants = path: user: lib.attrByPath (lib.splitString "." path ++ [ "enable" ]) false user;

  anyUserWants = path: lib.any (userWants path) (lib.attrValues enabledUsers);
in
lib.filterAttrs (path: _: anyUserWants path) catalogue
