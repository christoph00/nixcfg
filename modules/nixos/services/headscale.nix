{
  flake,
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (flake.lib) mkBoolOpt mkStrOpt;
  inherit (lib) mkDefault mkIf;
in
{

  config = mkIf config.services.headscale.enable {

    sys.state.directories = [ "/var/lib/headscale" ];

    services.headscale = {
      address = "0.0.0.0";
      port = 6005;
      settings = {
        server_url = "https://hs.r505.de:443";
        prefixes.v4 = "100.64.64.0/24";
        dns.search_domains = [ "ts.r505.de" ];
        dns.base_domain = "ts.r505.de";

      };

    };
  };

}
