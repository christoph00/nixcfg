{
  config,
  pkgs,
  lib,
  ...
}: let
  certDir = config.security.acme.certs."mx.r505.de".directory;
in {
  environment.systemPackages = [pkgs.vmt pkgs.vomit-sync pkgs.meli pkgs.mujmap pkgs.openssl];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "christoph@asche.co";
    };
    certs."mx.r505.de" = {
      domain = "mx.r505.de";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.cf-acme.path;
      dnsResolver = "1.1.1.1:53";
      postRun = ''
        sed -i 's/EC\ PRIVATE/PRIVATE/g' key.pem
      '';
    };
  };
  users.users.stalwart.extraGroups = ["acme"];
  services.stalwart = {
    enable = true;
    jmap = {
      enable = true;
      settings = {
        jmap-url = "https://jmap.r505.de";
        jmap-port = 8055;
      };
    };
    imap = {
      enable = true;
      settings = {
        log-level = "debug";
        cert-path = "${certDir}/cert.pem";
        key-path = "${certDir}/key.pem";
        jmap-url = "https://localhost:8055";
        bind-port-tls = 993;
        bind-addr = "127.0.0.1";
        cache-dir = "/usr/local/stalwart-imap/data";
      };
    };
  };
}
