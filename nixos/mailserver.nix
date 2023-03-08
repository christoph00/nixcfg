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
    openFirewall = true;
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
        jmap-url = "http://localhost:8055";
        bind-port-tls = 993;
        bind-addr = "0.0.0.0";
        cache-dir = "/usr/local/stalwart-imap/data";
      };
    };
  };

  services.alps = {
    enable = true;
    port = 8077;
  };

  systemd.services.alps.serviceConfig.ExecStart = lib.mkForce "${pkgs.alps}/bin/alps -addr 0.0.0.0:8077 -theme sourcehut imaps://mx.r505.de:993 smtps://mx.r505.de:465 https://cal.r505.de/dav.php";
}
