{
  lib,
  userConfig,
  ...
}:

let
  zenCfg = userConfig.programs.browser.zen or { };
  cfg = zenCfg.betterfox or { };

  settings = {
    # General
    "gfx.content.skia-font-cache-size" = 20;
    "content.notify.interval" = 100000;

    # GFX
    "gfx.canvas.accelerated.cache-size" = 512;

    # JavaScript
    "javascript.options.baselinejit.threshold" = 50;

    # Media cache
    "media.cache_readahead_limit" = 3600;
    "media.cache_resume_threshold" = 1800;

    # Image cache
    "image.mem.decode_bytes_at_a_time" = 32768;

    # Networking
    "network.buffer.cache.size" = 65535;
    "network.buffer.cache.count" = 48;
    "network.http.max-connections" = 1800;
    "network.http.max-persistent-connections-per-server" = 10;
    "network.http.max-urgent-start-excessive-connections-per-host" = 5;
    "network.http.request.max-start-delay" = 5;
    "network.dnsCacheExpiration" = 3600;
  };
in
{
  config = lib.mkIf ((zenCfg.enable or false) && (cfg.enable or false)) {
    programs.zen-browser.profiles.default.settings = lib.mapAttrs (_: lib.mkDefault) settings;
  };
}
