{
  config,
  lib,
  hostname,
  ...
}:
with lib; {
  useDHCP = mkDefault false;
  useNetworkd = mkDefault true;

  networking.hostname = "${hostname}";
  hostId = builtins.substring 0 8 (
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
  nameservers = [
    "1.1.1.1"
    "9.9.9.9"
  ];
  networkmanager = mkIf (builtins.elem config.nos.type ["desktop" "laptop"]) {
    enable = true;
    plugins = []; # disable all plugins, we don't need them
    dns = "systemd-resolved"; # use systemd-resolved as dns backend
    wifi = {
      powersave = true; # enable wifi powersaving
    };
  };
  hardware.wirelessRegulatoryDatabase = mkIf config.nos.type == "laptop" true;

  systemd.network.wait-online.enable = false;
}
