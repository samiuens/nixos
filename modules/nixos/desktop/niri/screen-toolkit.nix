{
  config,
  lib,
  pkgs,
  ...
}:

let
  niri = config.smi.desktop.niri;
  cfg = niri.screenToolkit;
in
{
  options.smi.desktop.niri.screenToolkit.enable =
    lib.mkEnableOption "Screen Toolkit plugin dependencies";

  config = lib.mkIf (niri.enable && cfg.enable) {
    environment.systemPackages = [
      # Capture, selection, and color picking.
      pkgs.grim
      pkgs.hyprpicker
      pkgs.slurp

      # OCR, barcode scanning, and image processing.
      (pkgs.tesseract5.override {
        enableLanguages = [
          "eng"
          "deu"
        ];
      })
      pkgs.imagemagick
      pkgs.zbar

      # Uploads, metadata, and media processing.
      pkgs.bc
      pkgs.coreutils
      pkgs.curl
      pkgs.ffmpeg
      pkgs.jq
      pkgs.procps
      pkgs.xdg-utils

      # Niri-compatible recording and annotation backends.
      pkgs.satty
      pkgs.wf-recorder
      pkgs.wl-screenrec
    ];
  };
}
