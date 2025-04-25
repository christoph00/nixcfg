{ lib, config, ... }:
{
  internal.hosts = {

    oca =
      let
        id = 110;
      in
      {
        inherit id;
        pubkey = "";
        zone = "oracle";
        architecture = "aarch64";
        roles = [
          "webserver"
          "development"
          "nas"
        ];
        net = {
          lan = "10.0.0.98";
          wan = "130.162.232.230";
          vpn = "10.87.87${lib.toString id}";
        };

      };

    oc1 =
      let
        id = 110;
      in
      {
        inherit id;
        pubkey = "";
        zone = "oracle";
        architecture = "x86_64";
        roles = [ ];
        net = {
          wan = null;
          lan = "10.0.0.22";
          vpn = "10.87.87${lib.toString id}";
        };
      };

  };
}
