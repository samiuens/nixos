{
  lib,
  config,
  ...
}:

let
  cfg = config.smi.hardware.audio;
in
{
  options.smi.hardware.audio = {
    enable = lib.mkEnableOption "audio support";

    pipewire = {
      enable = lib.mkEnableOption "PipeWire audio" // {
        default = true;
      };

      pulse = {
        enable = lib.mkEnableOption "PulseAudio compatibility through PipeWire" // {
          default = true;
        };
      };

      alsa = {
        enable = lib.mkEnableOption "ALSA support through PipeWire" // {
          default = true;
        };

        support32Bit = lib.mkEnableOption "32-bit ALSA support";
      };

      jack = {
        enable = lib.mkEnableOption "JACK compatibility through PipeWire";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    security.rtkit.enable = true;

    services.pulseaudio.enable = false;

    services.pipewire = {
      enable = cfg.pipewire.enable;
      audio.enable = cfg.pipewire.enable;
      alsa = {
        enable = cfg.pipewire.alsa.enable;
        support32Bit = cfg.pipewire.alsa.support32Bit;
      };
      pulse.enable = cfg.pipewire.pulse.enable;
      jack.enable = cfg.pipewire.jack.enable;
    };
  };
}
