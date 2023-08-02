{
  config,
  lib,
  pkgs,
  ...
}: {
  system.stateVersion = "23.11";
  hardware.enableRedistributableFirmware = true;

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_xanmod_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [acpi_call];

  boot.kernel.sysctl = {
    "max_user_watches" = 524288;
    "kernel.dmesg_restrict" = true;
    "kernel.unprivileged_bpf_disabled" = true;
    "kernel.unprivileged_userns_clone" = 1;
    "net.core.bpf_jit_harden" = true;
  };

  environment.systemPackages = [
    pkgs.git
    pkgs.killall
    pkgs.dnsutils
    pkgs.htop
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  i18n.extraLocaleSettings = lib.mkDefault {
    LC_TIME = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
  };

  services.openssh = {
    enable = true;
    hostKeys = [
      {
        bits = 4096;
        path = "/nix/persist/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        path = "/nix/persist/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };
  programs.mosh.enable = true;
}
