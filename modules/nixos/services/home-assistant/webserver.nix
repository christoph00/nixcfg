{config, ...}: {
  services.nginx.virtualHosts.hass = {
    serverName = "ha.r505.de";
    useACMEHost = "ha.r505.de";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
  };
  security.acme.certs."ha.r505.de" = {
    domain = "ha.r505.de";
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.cf-acme.path;
    dnsResolver = "1.1.1.1:53";
  };
}
