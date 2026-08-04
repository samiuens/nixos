{
  config,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/nixos
    ./disko.nix
    ./hardware-configuration.nix
  ];

  smi = {
    boot = {
      kernel = {
        enable = true;
        package = "default";
        modules = [ "r8168" ];
        blacklistedModules = [ "r8169" ];
        extraModulePackages = [ config.boot.kernelPackages.r8168 ];
      };

      limine = {
        enable = true;

        windows = {
          enable = true;
          partitionUuid = "3da67cbf-ba14-44c6-a5cf-5a9951594208";
        };
        secureBoot.enable = true;
      };

      plymouth.enable = true;
    };

    desktop = {
      gnome.enable = true;

      niri = {
        enable = true;
      };

      shared = {
        applications.enable = true;
        cursor = {
          enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 16;
        };
        fonts.enable = true;
      };
    };

    environment = {
      keyboard.enable = true;
      locale.enable = true;
      shell.enable = true;
      timezone = {
        enable = true;
        hardwareClockInLocalTime = true;
      };
    };

    hardware = {
      audio.enable = true;
      bluetooth.enable = true;

      cpu = {
        enable = true;
        vendor = "amd";
      };

      filesystem = {
        enable = true;
        root = "btrfs";
      };

      gpu = {
        enable = true;
        vendor = "amd";
        enable32Bit = true;
        loadInInitrd = true;

        firmware.enable = true;
        overdrive.enable = true;
      };

      power.enable = true;
      storage.enable = true;

      wifi = {
        enable = true;
        intelAx200.enable = true;
      };
    };

    networking = {
      dns.enable = true;
      networkmanager.enable = true;
    };

    packages = {
      btrfs-assistant.enable = true;
      comma.enable = true;
      coolercontrol.enable = true;
      graphify.enable = true;
      manager.enable = true;
      nix-ld.enable = true;
      nh = {
        enable = true;
        flake = "path:/home/smi/nixos";
      };
    };

    security.enable = true;

    services = {
      localsend.enable = true;
      netbird.enable = true;
      printing.enable = true;
      snapper.enable = true;
    };

    system = {
      users.enable = true;
      home-manager.enable = true;

      host = {
        enable = true;
        name = "smi-nix";
      };

      nix.enable = true;
    };
  };

  services.fwupd.enable = true;
  system.stateVersion = "26.05";
}
