{
  lib,
  config,
  flake,
  ...
}:
let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) mkBoolOpt;

  cfg = config.network;
in
{

  options.network.optimizeTcp = mkBoolOpt true;

  config = mkIf cfg.optimizeTcp {
    boot = {
      kernelModules = [
        "tls"
        "tcp_bbr"
      ];

      kernel.sysctl = {
        # Allow Ping for all users
        "net.ipv4.ping_group_range" = mkForce "0 2147483647";
        # TCP hardening
        # Prevent bogus ICMP errors from filling up logs.
        "net.ipv4.icmp_ignore_bogus_error_responses" = mkDefault 1;

        # Reverse path filtering causes the kernel to do source validation of
        # packets received from all interfaces. This can mitigate IP spoofing.
        "net.ipv4.conf.default.rp_filter" = mkDefault 1;
        "net.ipv4.conf.all.rp_filter" = mkDefault 1;

        # Do not accept IP source route packets (we're not a router)
        "net.ipv4.conf.all.accept_source_route" = mkDefault 0;
        "net.ipv6.conf.all.accept_source_route" = mkDefault 0;

        # Don't send ICMP redirects (again, we're on a router)
        "net.ipv4.conf.all.send_redirects" = mkDefault 0;
        "net.ipv4.conf.default.send_redirects" = mkDefault 0;

        # Refuse ICMP redirects (MITM mitigations)
        "net.ipv4.conf.all.accept_redirects" = mkDefault 0;
        "net.ipv4.conf.default.accept_redirects" = mkDefault 0;
        "net.ipv4.conf.all.secure_redirects" = mkDefault 0;
        "net.ipv4.conf.default.secure_redirects" = mkDefault 0;
        "net.ipv6.conf.all.accept_redirects" = mkDefault 0;
        "net.ipv6.conf.default.accept_redirects" = mkDefault 0;

        # Protects against SYN flood attacks
        "net.ipv4.tcp_syncookies" = mkDefault 1;

        # Incomplete protection again TIME-WAIT assassination
        "net.ipv4.tcp_rfc1337" = mkDefault 1;

        # And other stuff
        "net.ipv4.conf.all.log_martians" = mkDefault true;
        "net.ipv4.conf.default.log_martians" = mkDefault true;
        "net.ipv4.icmp_echo_ignore_broadcasts" = mkDefault true;
        "net.ipv6.conf.default.accept_ra" = mkDefault 0;
        "net.ipv6.conf.all.accept_ra" = mkDefault 0;
        "net.ipv4.tcp_timestamps" = mkDefault 0;

        # TCP optimization
        # TCP Fast Open is a TCP extension that reduces network latency by packing
        # data in the sender's initial TCP SYN. Setting 3 = enable TCP Fast Open for
        # both incoming and outgoing connections:
        "net.ipv4.tcp_fastopen" = mkDefault 3;

        # Bufferbloat mitigations + slight improvement in throughput & latency
        "net.ipv4.tcp_congestion_control" = mkDefault "bbr";
        "net.core.default_qdisc" = mkDefault "cake";

        "net.core.somaxconn" = mkDefault 8192;
        "net.ipv4.ip_local_port_range" = mkDefault "16384 65535";
        "net.ipv4.tcp_mtu_probing" = mkDefault 1;
        "net.ipv4.tcp_slow_start_after_idle" = mkDefault 0;
        "net.netfilter.nf_conntrack_generic_timeout" = mkDefault 60;
        "net.netfilter.nf_conntrack_max" = mkDefault 1048576;
        "net.netfilter.nf_conntrack_tcp_timeout_established" = mkDefault 600;
        "net.netfilter.nf_conntrack_tcp_timeout_time_wait" = mkDefault 1;

        # buffer limits: 32M max, 16M default
        "net.core.rmem_max" = mkDefault 33554432;
        "net.core.wmem_max" = mkDefault 33554432;
        "net.core.rmem_default" = mkDefault 16777216;
        "net.core.wmem_default" = mkDefault 16777216;
        "net.core.optmem_max" = mkDefault 40960;

        # Increase the maximum memory used by the TCP stack
        # https://blog.cloudflare.com/the-story-of-one-latency-spike/
        "net.ipv4.tcp_mem" = mkDefault "786432 1048576 26777216";
        "net.ipv4.tcp_rmem" = mkDefault "4096 1048576 2097152";
        "net.ipv4.tcp_wmem" = mkDefault "4096 65536 16777216";

        # http://www.nateware.com/linux-network-tuning-for-2013.html
        "net.core.netdev_max_backlog" = mkDefault 100000;
        "net.core.netdev_budget" = mkDefault 100000;
        "net.core.netdev_budget_usecs" = mkDefault 100000;
        "net.ipv4.tcp_max_syn_backlog" = mkDefault 30000;
        "net.ipv4.tcp_max_tw_buckets" = mkDefault 2000000;
        "net.ipv4.tcp_tw_reuse" = mkDefault 1;
        "net.ipv4.tcp_fin_timeout" = mkDefault 10;
        "net.ipv4.udp_rmem_min" = mkDefault 8192;
        "net.ipv4.udp_wmem_min" = mkDefault 8192;
      };
    };
  };
}
