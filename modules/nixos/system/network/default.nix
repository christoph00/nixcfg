{
  options,
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.network;
in
{
  imports = [ ./netbird.nix ];
  options.chr.system.network = with types; {
    enable = mkOpt types.bool true "Enable Network Config.";
    tweaks = mkOpt types.bool true "Enable Network Tweaks.";
    wifi-switch = mkOpt types.bool config.chr.system.laptop.enable "Disable wifi on Ethernet.";
  };

  config = mkIf cfg.enable {
    networking.useDHCP = mkDefault false;
    networking.useNetworkd = mkDefault true;

    #networking.hostName = "${hostname}";
    networking.hostId = builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    # networking.useHostResolvConf = false;
    # services.resolved = {
    #   enable = builtins.elem config.chr.type ["server" "vm"];
    #   dnssec = "false";
    #   fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
    #   llmnr = "true";
    #   extraConfig = ''
    #     DNSStubListenerExtra=[::1]:53
    #     DNSOverTLS=yes
    #   '';
    # };

    # 1-7dhqcaaa4aaeaaya6kpt7egqaflhgiiaeeiabca.max.rethinkdns.com

    #networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

    services.avahi.enable = true;

    networking.networkmanager = {
      enable = builtins.elem config.chr.type [
        "desktop"
        "laptop"
      ];
      plugins = [ ]; # disable all plugins, we don't need them
      # dns = "systemd-resolved"; # use systemd-resolved as dns backend
      wifi = {
        powersave = true; # enable wifi powersaving
      };
      connectionConfig."connection.mdns" = 2;
    };
    systemd.network.wait-online.enable = false;

    boot = mkIf cfg.tweaks {
      kernelModules = [
        "tls"
        "tcp_bbr"
      ];
      kernel.sysctl = {
        # TCP hardening
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
        # And other stuff
        "net.ipv4.conf.all.log_martians" = true;
        "net.ipv4.conf.default.log_martians" = true;
        "net.ipv4.icmp_echo_ignore_broadcasts" = true;
        "net.ipv6.conf.default.accept_ra" = 0;
        "net.ipv6.conf.all.accept_ra" = 0;
        "net.ipv4.tcp_timestamps" = 0;

        # TCP optimization
        # TCP Fast Open is a TCP extension that reduces network latency by packing
        # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
        # both incoming and outgoing connections:
        "net.ipv4.tcp_fastopen" = 3;
        # Bufferbloat mitigations + slight improvement in throughput & latency
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";

        # Other stuff I am too lazy to document
        "net.core.optmem_max" = 65536;
        "net.core.rmem_default" = 1048576;
        "net.core.rmem_max" = 16777216;
        "net.core.somaxconn" = 8192;
        "net.core.wmem_default" = 1048576;
        "net.core.wmem_max" = 16777216;
        "net.ipv4.ip_local_port_range" = "16384 65535";
        "net.ipv4.tcp_max_syn_backlog" = 8192;
        "net.ipv4.tcp_max_tw_buckets" = 2000000;
        "net.ipv4.tcp_mtu_probing" = 1;
        "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
        "net.ipv4.tcp_slow_start_after_idle" = 0;
        "net.ipv4.tcp_tw_reuse" = 1;
        "net.ipv4.tcp_wmem" = "4096 65536 16777216";
        "net.ipv4.udp_rmem_min" = 8192;
        "net.ipv4.udp_wmem_min" = 8192;
        "net.netfilter.nf_conntrack_generic_timeout" = 60;
        "net.netfilter.nf_conntrack_max" = 1048576;
        "net.netfilter.nf_conntrack_tcp_timeout_established" = 600;
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = 1;
      };
    };
  };
}
