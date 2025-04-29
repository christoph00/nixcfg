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
          vpn = "10.87.87.${toString id}";
        };

      };

    oc1 =
      let
        id = 111;
      in
      {
        inherit id;
        wgPubkey = "Lw5CwsmceU63CHIC3kDU0//vQf9kwL4Pt+HlWHrDPi4=";
        zone = "oracle";
        architecture = "x86_64";
        roles = [ "vpn" ];
        net = {
          wan = "158.101.169.88";
          lan = "10.0.0.142";
          vpn = "10.87.87.${toString id}";
        };
      };
    oc2 =
      let
        id = 112;
      in
      {
        inherit id;
        wgPubkey = "6oGf+oPvLIinnun4OuJgurBRzlJLQKhVmCbhaQFQIXc=";
        zone = "oracle";
        architecture = "x86_64";
        roles = [ "vpn" ];
        net = {
          wan = "130.162.234.237";
          lan = "10.0.0.151";
          vpn = "10.87.87.${toString id}";
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
        wgPubkey = "8Nv6ln4y5XVm13r2rhlMgi0KJZVI+Vz3nR7hhnWjMHg=";
        roles = [
          "vpn"
          "webserver"
          "router"
          "nas"
          "smarthome"
        ];
        net = {
          wan = "dynamic";
          lan = "192.168.2.2";
          vpn = "10.87.87.${toString id}";
        };
      };
    tower =
      let
        id = 51;
      in
      {
        inherit id;
        zone = "home";
        architecture = "x86_64";
        wgPubkey = "+3J7uu4QlrYhNPrttXvH6JXySDuZw71KV763oP6A/0A=";
        roles = [
          "vpn"
          "desktop"
          "gaming"
          "nas"
          "development"
          "headless-desktop"
          "game-stream"
          "media"
        ];
        net = {
          lan = "dhcp";
          wan = null;
          vpn = "10.87.87.${toString id}";
        };
      };
    x13 =
      let
        id = 52;
      in
      {
        inherit id;
        zone = "home";
        architecture = "x86_64";
        wgPubkey = "Ik2N2lpZ7mlWnYGktygruKsLyytd210/B4WcS3gDCiI=";
        roles = [
          "vpn"
          "desktop"
          "development"
        ];
        net = {
          lan = "dhcp";
          wan = null;
          vpn = "10.87.87.${toString id}";
        };
      };

    star =
      let
        id = 33;
      in
      {
        inherit id;
        zone = "external";
        architecture = "x86_64";
        roles = [ ];
        net = {
          lan = null;
          wan = "77.223.215.81";
          vpn = "10.87.87.${toString id}";
        };
      };

  };

  internal.subnets = {
    home = "192.168.2.0/24";
    oracle = "10.0.0.0/24";
    vpn = "10.87.87.0/24";
  };
}
