{userConfig, ...}: {
  disko.devices = {
    disk = {
      system = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x50026b7784dbad23";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "EFI";
              type = "EF00";
              start = "4096s";
              end = "2101247s";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["fmask=0077" "dmask=0077"];
              };
            };

            root = {
              label = "root";
              start = "2101248s";
              end = "396813152s";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };

            swap = {
              uuid = "a7818b25-b04d-4c76-b1ab-9282521d2dc3";
              start = "396813153s";
              end = "468862061s";
              content = {
                type = "swap";
              };
            };
          };
        };
      };

      m2 = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_22195J800057";
        content = {
          type = "gpt";
          partitions = {
            data = {
              label = "M2";
              start = "2048s";
              end = "1953523711s";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home/${userConfig.name}/m2";
                mountOptions = ["defaults" "nofail"];
              };
            };
          };
        };
      };
    };
  };
}
