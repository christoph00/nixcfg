{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.conf.base;
in {
  options.conf.base = {
    enable = mkEnableOption "Base Config";
    persist = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    i18n.defaultLocale = lib.mkDefault "de_DE.UTF-8";
    time.timeZone = "Europe/Berlin";

    hardware.enableRedistributableFirmware = true;

    security.sudo.wheelNeedsPassword = false;

    system.nssDatabases.hosts = lib.mkMerge [
      (lib.mkBefore ["mdns_minimal [NOTFOUND=return]"])
      (lib.mkAfter ["mdns"])
    ];

    networking.firewall.logRefusedPackets = false;
    networking.firewall.logRefusedConnections = false;

    systemd.services = {
      systemd-networkd-wait-online.enable = lib.mkForce false;
      systemd-networkd.restartIfChanged = lib.mkForce false;
      firewall.restartIfChanged = false;
    };

    users.mutableUsers = false;
    security.pam.loginLimits = [
      {
        domain = "@wheel";
        item = "nofile";
        type = "soft";
        value = "524288";
      }
      {
        domain = "@wheel";
        item = "nofile";
        type = "hard";
        value = "1048576";
      }
    ];

    systemd = {
      enableEmergencyMode = false;

      # For more detail, see:
      #   https://0pointer.de/blog/projects/watchdog.html
      watchdog = {
        # systemd will send a signal to the hardware watchdog at half
        # the interval defined here, so every 10s.
        # If the hardware watchdog does not get a signal for 20s,
        # it will forcefully reboot the system.
        runtimeTime = "20s";
        # Forcefully reboot if the final stage of the reboot
        # hangs without progress for more than 30s.
        # For more info, see:
        #   https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
        rebootTime = "30s";
      };

      sleep.extraConfig = ''
        AllowSuspend=no
        AllowHibernation=no
      '';
    };

    # use TCP BBR has significantly increased throughput and reduced latency for connections
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    programs.fuse.userAllowOther = true;

    nix = {
      #generateNixPathFromInputs = true;
      #generateRegistryFromInputs = true;
      #linkInputs = true;
      settings = {
        substituters = [
          "https://chr.cachix.org"
          "https://hyprland.cachix.org"
          "https://nix-community.cachix.org"
        ];
        trusted-public-keys = [
          "chr.cachix.org-1:8Z0vNVd8hK8lVU53Y26GHDNc6gv3eFzBNwSYOcUvsgA="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
        trusted-users = ["root" "@wheel"];
        auto-optimise-store = mkDefault true;
        experimental-features = ["nix-command" "flakes" "repl-flake"];
        warn-dirty = false;
      };
      package = pkgs.nixUnstable;
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d --max-freed $((64 * 1024**3))";
      };
      optimise = {
        automatic = true;
        dates = ["weekly"];
      };
    };

    nix.settings.max-free = lib.mkDefault (1000 * 1000 * 1000);
    nix.settings.min-free = lib.mkDefault (128 * 1000 * 1000);
    nix.settings.builders-use-substitutes = true;
    nix.settings.connect-timeout = 5;

    nixpkgs = {
      config = {
        allowUnfree = true;
      };
    };

    documentation.info.enable = false;

    services.nscd.enableNsncd = true;

    services.openssh = {
      enable = true;
      # Harden
      passwordAuthentication = false;
      permitRootLogin = "no";
      # Automatically remove stale sockets
      extraConfig = ''
        StreamLocalBindUnlink yes
      '';
      # Allow forwarding ports to everywhere
      gatewayPorts = "clientspecified";

      hostKeys = [
        # mkIf
        # cfg.persist
        {
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
