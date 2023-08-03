{
  config,
  lib,
  hostname,
  ...
}:
with lib; {
  networking.useDHCP = mkDefault false;
  networking.useNetworkd = mkDefault true;

  networking.hostName = "${hostname}";
  networking.hostId = builtins.substring 0 8 (
    builtins.hashString "md5" config.networking.hostName
  );
  networking.useHostResolvConf = false;
  services.resolved = {
    enable = lib.mkDefault true;
    dnssec = "false";
    llmnr = "true";
    extraConfig = ''
      DNSStubListenerExtra=[::1]:53
    '';
  };
  networking.nameservers = [
    "1.1.1.1"
    "9.9.9.9"
  ];
  networking.networkmanager = mkIf (builtins.elem config.nos.type ["desktop" "laptop"]) {
    enable = true;
    plugins = []; # disable all plugins, we don't need them
    dns = "systemd-resolved"; # use systemd-resolved as dns backend
    wifi = {
      powersave = true; # enable wifi powersaving
    };
  };
  systemd.network.wait-online.enable = false;

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
}
