{ lib }:

{
  discoverHosts = import ./discover-hosts.nix { inherit lib; };
  getAdminUsers = import ./get-admin-users.nix { inherit lib; };
  importModulesRecursive = import ./import-modules-recursive.nix { inherit lib; };
  mkUserGroups = import ./mk-user-groups.nix { inherit lib; };
  mkNixosConfigurations = import ./mk-nixos-configurations.nix { inherit lib; };
  userConfigModule = import ./user-config-module.nix { inherit lib; };
}
