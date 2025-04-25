{ lib, config, ... }:
{
  internal.hosts = {

    oca =
      let
        id = 110;
      in
      {
        inherit id;
        wgPubkey = "bBI/RIggxYehA9NjKlLG+5T1rxpWSndnj45roPLVZxc=";
        zone = "oracle";
        architecture = "aarch64";
        roles = [
          "vpn"
          "webserver"
          "development"
          "nas"
        ];
        net = {
          lan = "10.0.0.98";
          wan = "130.162.232.230";
          vpn = "10.87.87.${lib.toString id}";
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
        roles = [ "vpn" ];
        net = {
          wan = null;
          lan = "10.0.0.22";
          vpn = "10.87.87.${lib.toString id}";
        };
      };
    lsrv =
      let
        id = 50;
      in
      {
        inherit id;
        zone = "home";
        architecture = "x86_64";
        wgPublicKey = "8Nv6ln4y5XVm13r2rhlMgi0KJZVI+Vz3nR7hhnWjMHg=";
        roles = [
          "vpn"
          "webserver"
          "router"
          "nas"
        ];
        net = {
          wan = "dynamic";
          lan = "192.168.2.2";
          vpn = "10.87.87.${lib.toString id}";
        };
      };
  };

  interal.subnets = {
    home = "192.168.2.0/24";
    oracle = "10.0.0.0/24";
    vpn = "10.87.87.0/24";
  };
}
