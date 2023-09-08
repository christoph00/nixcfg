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
  # networking.useHostResolvConf = false;
  # services.resolved = {
  #   enable = lib.mkDefault true;
  #   dnssec = "false";
  #   fallbackDns = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];
  #   llmnr = "true";
  #   extraConfig = ''
  #     DNSStubListenerExtra=[::1]:53
  #     DNSOverTLS=yes
  #   '';
  # };

  # 1-7dhqcaaa4aaeaaya6kpt7egqaflhgiiaeeiabca.max.rethinkdns.com

  networking.nameservers = ["1.1.1.1#one.one.one.one" "1.0.0.1#one.one.one.one"];

  networking.networkmanager = mkIf (builtins.elem config.nos.type ["desktop" "laptop"]) {
    enable = true;
    plugins = []; # disable all plugins, we don't need them
    # dns = "systemd-resolved"; # use systemd-resolved as dns backend
    wifi = {
      powersave = true; # enable wifi powersaving
    };
  };
  systemd.network.wait-online.enable = false;
}
