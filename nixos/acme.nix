{
  pkgs,
  config,
  ...
}: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "christoph@asche.co";
    };
    certs."r505.de" = {
      domain = "*.r505.de";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.cf-acme.path;
      dnsResolver = "1.1.1.1:53";
    };
  };
}
