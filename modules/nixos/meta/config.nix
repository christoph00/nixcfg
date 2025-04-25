{ lib, config, ... }:
{
  internal.hosts = {

    oca = {
      id = 110;
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
      };

    };

    oc1 = {
      id = 111;
      pubkey = "";
      zone = "oracle";
      architecture = "x86_64";
      roles = [ ];
      net = {
        wan = null;
        lan = "10.0.0.22";
      };
    };
    oc2 = {
      id = 112;
      pubkey = "";
      zone = "oracle";
      architecture = "x86_64";
      roles = [ ];
      net = {
        lan = "10.0.0.31";
        wan = null;
      };
    };

    tower = {
      id = 210;
      pubkey = "";
      zone = "home";
      architecture = "x86_64";
      roles = [
        "desktop"
        "development"
        "nas"
        "webserver"
        "headless-desktop"
        "gamestream"
        "gaming"
      ];
      net = {
        lan = "dhcp";
      };
    };

    x13 = {
      id = 211;
      pubkey = "";
      zone = "home";
      architecture = "x86_64";
      roles = [
        "desktop"
        "laptop"
        "development"
      ];
      net.lan = "dhcp";
    };

    lsrv = {
      id = 200;
      pubkey = "";
      zone = "home";
      architecture = "x86_64";
      roles = [
        "router"
        "nas"
        "webserver"
      ];
      net = {
        lan = "192.168.2.2";
        wan = "dynamic";
      };
    };

    star = {
      id = 151;
      pubkey = "";
      zone = "external";
      architecture = "x86_64";
      roles = [ ];
    };

    bootstrap = {
      id = 99;
      pubkey = "";
      zone = "external";
      architecture = "x86_64";
      roles = [ ];
    };

    okd = {
      id = 152;
      pubkey = "";
      zone = "external";
      architecture = "x86_64";
      roles = [ ];
    };

  };
}
