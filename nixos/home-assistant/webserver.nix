{config, ...}: {
  services.nginx.virtualHosts.hass = {
    serverName = "home.r505.de";
    useACMEHost = "home.r505.de";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
  };
  security.acme.certs."home.r505.de" = {
    domain = "home.r505.de";
    dnsProvider = "cloudflare";
    credentialsFile = config.age.secrets.cf-acme.path;
    dnsResolver = "1.1.1.1:53";
  };
}
