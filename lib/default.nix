{ lib }:

{
  appCatalogue = import ./app-catalogue.nix;
  discoverHosts = import ./discover-hosts.nix { inherit lib; };
  enabledCatalogueEntries = import ./enabled-catalogue-entries.nix { inherit lib; };
  getAdminUsers = import ./get-admin-users.nix { inherit lib; };
  importModulesRecursive = import ./import-modules-recursive.nix { inherit lib; };
  mkUserGroups = import ./mk-user-groups.nix { inherit lib; };
  mkDarwinConfigurations = import ./mk-darwin-configurations.nix { inherit lib; };
  mkNixosConfigurations = import ./mk-nixos-configurations.nix { inherit lib; };
  mkTmuxGitStatus = import ./mk-tmux-git-status.nix { inherit lib; };
  nixUsable = import ./nix-usable.nix { inherit lib; };
  preferNixPackage = import ./prefer-nix-package.nix { inherit lib; };
  userConfigModule = import ./user-config-module.nix { inherit lib; };
  zenProfile = import ./zen-profile.nix { inherit lib; };
}
