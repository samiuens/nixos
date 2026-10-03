{
  lib,
  pkgs,
  inputs,
  hostName,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.editor.zed or { };

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  useNixPackage = smiLib.preferNixPackage pkgs "programs.editor.zed";

  # A store path is an unlocked flake reference; narHash locks it.
  flake = ''builtins.getFlake "path:${inputs.self}?narHash=${inputs.self.narHash}"'';
  hostOptions = "(${flake}).${
    if isDarwin then "darwinConfigurations" else "nixosConfigurations"
  }.${hostName}.options";

  baseSettings = {
    languages.Nix.language_servers = [
      "nixd"
      "!nil"
    ];

    # Store paths, not `extraPackages`: that wraps the package, which is null on darwin.
    lsp.nixd = {
      binary.path = lib.getExe pkgs.nixd;

      settings = {
        formatting.command = [ (lib.getExe pkgs.nixfmt) ];
        nixpkgs.expr = ''import "${inputs.nixpkgs}" { }'';
        options = {
          ${if isDarwin then "nix-darwin" else "nixos"}.expr = hostOptions;
          home-manager.expr = "${hostOptions}.home-manager.users.type.getSubOptions [ ]";
        };
      };
    };
  };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.zed-editor = {
      enable = true;
      package = if useNixPackage then pkgs.zed-editor else null;

      extensions = lib.unique ([ "nix" ] ++ (cfg.extensions or [ ]));
      userSettings = lib.recursiveUpdate baseSettings (cfg.settings or { });
    };
  };
}
