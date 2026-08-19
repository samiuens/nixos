{
  inputs,
  lib,
  pkgs,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.browser.zen or { };

  inherit (pkgs.stdenv.hostPlatform) isDarwin;

  mkExtensionSettings = builtins.mapAttrs (
    _extensionId: amoSlug: {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/${amoSlug}/latest.xpi";
      installation_mode = "force_installed";
    }
  );

  policies = {
    ExtensionSettings = mkExtensionSettings {
      "uBlock0@raymondhill.net" = "ublock-origin";
      "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
      "addon@darkreader.org" = "darkreader";
      "sponsorBlocker@ajay.app" = "sponsorblock";
    };

    "3rdparty".Extensions."uBlock0@raymondhill.net".adminSettings = builtins.readFile ./ublock.json;
  };
in
{
  # Zen ships as a signed application bundle on darwin, where the flake refuses to
  # apply policies because doing so would mutate that bundle. Extensions are
  # installed by hand there; every other Zen setting still applies.
  config = lib.mkIf ((cfg.enable or false) && !isDarwin) {
    programs.zen-browser = {
      inherit policies;

      # Zen resolves its executable to the unwrapped store path, so embed the
      # policies there in addition to Home Manager's outer finalPackage wrapper.
      unwrappedPackage =
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight-unwrapped.override
          {
            inherit policies;
          };
    };
  };
}
