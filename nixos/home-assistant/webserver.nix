{pkgs, ...}: {
  services.nginx.virtualHosts.hass = {
    serverName = "ha.net.r505.de";
    useACMEHost = "net.r505.de";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:8123";
      proxyWebsockets = true;
    };
  };
}
