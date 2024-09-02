{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,

  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.

  # All other arguments come from the module system.
  config,

  ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.system.kernel;
in
{

  options.internal.system.kernel = with types; { };

  config = (
    mkMerge [
      {
        boot.kernel.sysctl = {
          # The Magic SysRq key is a key combo that allows users connected to the
          # system console of a Linux kernel to perform some low-level commands.
          # Disable it, since we don't need it, and is a potential security concern.
          "kernel.sysrq" = 0;

          ## TCP hardening
          # Prevent bogus ICMP errors from filling up logs.
          "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
          # Reverse path filtering causes the kernel to do source validation of
          # packets received from all interfaces. This can mitigate IP spoofing.
          "net.ipv4.conf.default.rp_filter" = 1;
          "net.ipv4.conf.all.rp_filter" = 1;
          # Do not accept IP source route packets (we're not a router)
          "net.ipv4.conf.all.accept_source_route" = 0;
          "net.ipv6.conf.all.accept_source_route" = 0;
          # Don't send ICMP redirects (again, we're on a router)
          "net.ipv4.conf.all.send_redirects" = 0;
          "net.ipv4.conf.default.send_redirects" = 0;
          # Refuse ICMP redirects (MITM mitigations)
          "net.ipv4.conf.all.accept_redirects" = 0;
          "net.ipv4.conf.default.accept_redirects" = 0;
          "net.ipv4.conf.all.secure_redirects" = 0;
          "net.ipv4.conf.default.secure_redirects" = 0;
          "net.ipv6.conf.all.accept_redirects" = 0;
          "net.ipv6.conf.default.accept_redirects" = 0;
          # Protects against SYN flood attacks
          "net.ipv4.tcp_syncookies" = 1;
          # Incomplete protection again TIME-WAIT assassination
          "net.ipv4.tcp_rfc1337" = 1;

          ## TCP optimization
          # TCP Fast Open is a TCP extension that reduces network latency by packing
          # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
          # both incoming and outgoing connections:
          "net.ipv4.tcp_fastopen" = 3;
          # Bufferbloat mitigations + slight improvement in throughput & latency
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.core.default_qdisc" = "cake";
        };
        boot.kernelModules = [ "tcp_bbr" ];
      }
      (mkIf config.internal.isGraphical {
        boot.kernelPackages = pkgs.linuxPackages_cachyos;
        chaotic.scx.enable = true; # by default uses scx_rustland scheduler

        boot.kernelParams = [ "mitigations=off" ]; # disable mitigations on desktop

      })
      (mkIf config.internal.isHeadless { boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_cachyos-server; })
    ]
  );
}
