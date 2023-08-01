{
  config,
  lib,
  hostname,
  ...
}: {
  networking.useHostResolvConf = false;
  services.resolved = {
    enable = lib.mkDefault true;
    dnssec = "false";
    llmnr = "true";
    extraConfig = ''
      DNSStubListenerExtra=[::1]:53
    '';
  };
}
