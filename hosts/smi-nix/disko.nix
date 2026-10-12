_:

let
  btrfsMountOptions = [
    "compress=zstd:3"
    "noatime"
  ];
in
{
  disko.devices.disk.system = {
    type = "disk";
    device = "/dev/disk/by-id/nvme-eui.0025385981b0b624";

    content = {
      type = "gpt";

      partitions = {
        ESP = {
          name = "ESP";
          label = "esp";
          start = "1M";
          size = "1G";
          type = "EF00";

          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        system = {
          size = "100%";
          label = "nixos";

          content = {
            type = "luks";
            name = "crypted";
            extraFormatArgs = [
              "--type"
              "luks2"
            ];
            settings = {
              allowDiscards = true;
              crypttabExtraOpts = [ "tpm2-device=auto" ];
            };

            content = {
              type = "btrfs";
              extraArgs = [
                "-f"
                "-L"
                "nixos"
              ];

              subvolumes = {
                "@root" = {
                  mountpoint = "/";
                  mountOptions = btrfsMountOptions;
                };

                "@home" = {
                  mountpoint = "/home";
                  mountOptions = btrfsMountOptions;
                };

                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = btrfsMountOptions;
                };

                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = btrfsMountOptions;
                };

                "@cache" = {
                  mountpoint = "/var/cache";
                  mountOptions = btrfsMountOptions;
                };

                "@var-tmp" = {
                  mountpoint = "/var/tmp";
                  mountOptions = btrfsMountOptions;
                };

                "@spool" = {
                  mountpoint = "/var/spool";
                  mountOptions = btrfsMountOptions;
                };

                "@snapshots" = {
                  mountpoint = "/.snapshots";
                  mountOptions = [ "noatime" ];
                };

                "@home-snapshots" = {
                  mountpoint = "/home/.snapshots";
                  mountOptions = [ "noatime" ];
                };

                "@swap" = {
                  mountpoint = "/swap";
                  mountOptions = [ "noatime" ];
                  swap.swapfile.size = "32G";
                };
              };
            };
          };
        };
      };
    };
  };

  disko.devices.disk.data = {
    type = "disk";
    device = "/dev/disk/by-id/ata-ST2000DM008-2FR102_ZFL5L2VJ";

    content = {
      type = "gpt";

      partitions.data = {
        size = "100%";
        label = "data";

        content = {
          type = "btrfs";
          extraArgs = [
            "-f"
            "-L"
            "data"
          ];

          subvolumes."@data" = {
            mountpoint = "/mnt/data";
            mountOptions = btrfsMountOptions ++ [
              "nofail"
              "x-systemd.device-timeout=10s"
              "x-gvfs-show"
              "x-gvfs-name=Data"
            ];
          };
        };
      };
    };
  };

  systemd.tmpfiles.rules = [ "d /mnt/data 0755 smi users -" ];
}
