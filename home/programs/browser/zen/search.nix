{
  pkgs,
  lib,
  userConfig,
  ...
}:

let
  cfg = userConfig.programs.browser.zen or { };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.zen-browser.profiles.default.search = {
      force = true;
      default = "brave-search";
      privateDefault = "brave-search";

      engines = {
        "brave-search" = {
          name = "Brave Search";
          urls = [
            {
              template = "https://search.brave.com/search";
              params = [
                {
                  name = "q";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://upload.wikimedia.org/wikipedia/commons/d/da/Brave_search_logo.png";
          definedAliases = [
            "@b"
          ];
        };
        "nixos" = {
          name = "Nix Packages";
          urls = [
            {
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "query";
                  value = "{searchTerms}";
                }
                {
                  name = "channel";
                  value = "unstable";
                }
              ];
            }
          ];
          icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
          definedAliases = [ "@np" ];
        };
        "makerworld" = {
          name = "Makerworld";
          urls = [
            {
              template = "https://makerworld.com/en/search/models";
              params = [
                {
                  name = "keyword";
                  value = "{searchTerms}";
                }
              ];
            }
          ];
          icon = "https://makerworld.com/favicon_new.png";
          definedAliases = [
            "@mw"
          ];
        };
        # Add alias to the built-in engines (no duplicates)
        duckduckgo.metaData.alias = "@ddg";
        google.metaData.alias = "@g";

        # Disable default engines
        bing.metaData.hidden = "true";
        ecosia.metaData.hidden = "true";
        wikipedia.metaData.hidden = "true";
        perplexity.metaData.hidden = "true";
      };
    };
  };
}
