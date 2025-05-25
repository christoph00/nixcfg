# #
# Z170 Extreme4 P7.50
# i7-6700k
# RX580 Sapphire
##
{
  pkgs,
  flake,
  lib,
  perSystem,
  ...
}:
let
  inherit (flake.lib) enabled;
in
{
  imports = [ flake.modules.nixos.host ];
  facter.reportPath = ./facter.json;
  networking.hostName = "tower";
  hw.cpu = "intel";
  hw.gpu = "amd";
  hw.ram = 32;
  host.graphical = true;
  host.gaming = true;

  svc.actions-runner = enabled;

  desktop.enable = true;
  desktop.remote = true;
  desktop.gaming.enable = true;
  desktop.gaming.proton = perSystem.self.proton-cachyos-bin.steamcompattool;
  desktop.autologin = true;

  desktop.games = {
    oblivion = {
      exe = "/home/christoph/Games/Oblivion/OblivionRemastered.exe";
      gameid = "2623190";
      icon = {
        url = "https://cdn2.steamgriddb.com/icon/beddc9f9e1c9b438dc4246e494644ce4.ico";
        sha256 = "sha256-tJkkjbDw6Ok7rghwO3G13gqOxBSseKZWYXVX6lbpkXg=";
      };
      cover = {
        url = "https://cdn2.steamgriddb.com/grid/97d2ff5928c5e71eb02cece4fcd57337.png";
        sha256 = "sha256-WInirFJ7WOnPZQy9O28JFR2a3eKXBxbDsHwRvOr9oMI=";
      };
    };
    cyberpunk2077 = {
      exe = "/home/christoph/Games/Cyberpunk2077/bin/x64/Cyberpunk2077.exe";
      gameid = "1091500";
      icon = {
        url = "https://cdn2.steamgriddb.com/icon/e0481545062e383969b6c020ad73e2f8.ico";
        sha256 = "sha256-PZZLXT/4MMuOknKxv/4hRTzB18+8LlTksYGwci/wx1o=";
      };
      cover = {
        url = "https://cdn2.steamgriddb.com/grid/4030e2eebb977639f8836aa25a293e40.png";
        sha256 = "sha256-jvMb98Oeb/zw78yCUg2GnHXjLx5piLT41NgsxHcDNF8=";
      };
    };
    kdc = {
      name = "Kingdom Come Delivernce II";
      exe = "/media/Games/Kingdom Come Deliverance/bin/Win64/KingdomCome.exe";
      gameid = "379430";
      icon = {
        url = "https://cdn2.steamgriddb.com/icon/b0fae80dbb4cabab2a00827fd7389f21.ico";
        sha256 = "sha256-4AlJBnrz8HWFf3BAbc5QGo+L/zeFEqdgCZjDgGqKU2g=";

      };
      cover = {
        url = "https://cdn2.steamgriddb.com/grid/107e5674373e2e3e4b1a0fc42b7bb190.png";
        sha256 = "sha256-4PTClV/1aqrEmfK2SFJPxEIySaOtGnkce/X/V30fd/0=";
      };
    };
    sims4 = {
      name = "Sims 4";
      exe = "/media/Games/Sims4/Game/Bin/TS4_x64.exe";
      gameid = "1222670";
      store = "ea";
      icon = {
        url = "https://cdn2.steamgriddb.com/icon/9fc664916bce863561527f06a96f5ff3.ico";
        sha256 = "sha256-lzpG3meHStM0z/Ltocn5nFjH/Aa842bdhGWPuvr7fV0=";

      };
      cover = {
        url = "https://cdn2.steamgriddb.com/grid/5c1d8b6ff107dafb76906e0334e62a87.png";
        sha256 = "sha256-H++/rHaMtY4X2JGnBaZKJ60hYo3y80xnhxhhSjU+qMU=";
      };

    };
  };

  sys.boot.secureBoot = true;
  sys.disk.device = "/dev/nvme0n1";
  sys.disk.encrypted = true;

  services.sabnzbd = enabled;

  fileSystems = {
    "/media/Games" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = [
        "subvol=@games"
        "noatime"
        "compress-force=zstd"
      ];
    };

    "/media/ssd-data" = {
      device = "/dev/disk/by-label/ssd-data";
      fsType = "btrfs";
      options = [
        "subvol=@data"
        "noatime"
        "compress-force=zstd"
      ];
    };

    "/media/hdd-data" = {
      device = "/dev/disk/by-uuid/25fc5836-72df-4881-8760-af49333fa485";
      fsType = "btrfs";
      options = [
        "subvol=@data"
        "noatime"
        "compress-force=zstd"
      ];
    };

  };

  environment.systemPackages = [
    pkgs.amdgpu_top
    pkgs.libva-utils
  ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      vulkan-loader
      vulkan-extension-layer
      vulkan-validation-layers
      amdvlk
    ];
    extraPackages32 = with pkgs; [ driversi686Linux.amdvlk ];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.amdgpu = {
    opencl.enable = true;
    initrd.enable = true;
    legacySupport.enable = true;
    amdvlk.enable = true;
    amdvlk.support32Bit.enable = true;
  };

  environment.variables = {
    # RADV_PERFTEST = "sam,video_decode,transfer_queue";
    LIBVA_DRIVER_NAME = "radeonsi";
    VDPAU_DRIVER = "radeonsi";
    ROC_ENABLE_PRE_VEGA = "1";

    # VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json";

    VK_DRIVER_FILES = lib.concatStringsSep ":" [
      "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json"
      "/run/opengl-driver/share/vulkan/icd.d/amd_icd64.json"
      "/run/opengl-driver-32/share/vulkan/icd.d/amd_icd32.json"
    ];

    VK_ICD_FILENAMES = lib.concatStringsSep ":" [
      "${pkgs.mesa}/share/vulkan/icd.d/radeon_icd.x86_64.json" # Mesa RADV 64-bit
      "${pkgs.driversi686Linux.mesa}/share/vulkan/icd.d/radeon_icd.i686.json" # Mesa RADV 32-bit
    ];

    AMD_VULKAN_ICD = "RADV";

    MESA_LOADER_DRIVER_OVERRIDE = "radeonsi";
  };

  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];

  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
  ];

  boot.kernelModules = [
    "kvm-intel"
    "acpi_call"
    "i2c_dev"
    "amdgpu"
  ];
  boot.kernelParams = [
    # "mem_sleep_default=deep"
    "amdgpu.gttsize=8192"
    "amdgpu.ignore_crat=1"
    "radeon.si_support=0"
    "radeon.cik_support=0"
    "amdgpu.si_support=1"
    "amdgpu.cik_support=1"
  ];
  boot.blacklistedKernelModules = [ "fglrx" ];
  boot.initrd = {
    availableKernelModules = [
      "xhci_pci"
      "ahci"
      "nvme"
      "amdgpu"
    ];
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource0_resize}="13"
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x67df", ATTR{resource2_resize}="3"
  '';

}
