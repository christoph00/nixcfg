{
  options,
  config,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.meta;
  hostOptions = with lib;
  with types; {
    zone = mkOption {
      type = str;
      default = "public";
    };
    ipv4 = mkOption {
      type = str;
    };

    wg = mkOption {
      type = nullOr str;
      default = null;
    };

    services = mkOption {
      type = nullOr (listOf str);
      default = null;
    };
  };
in {
  options.chr.meta = with lib;
  with types; {
    tldomain = mkOption {
      type = str;
    };
    domain = mkOption {
      type = str;
      default = "${config.chr.meta.currentHost.zone}.${config.chr.meta.tldomain}";
    };
    hosts = mkOption {
      type = attrsOf (submodule [{options = hostOptions;}]);
    };
    currentHost = mkOption {
      type = submodule [{options = hostOptions;}];
      default = config.chr.meta.hosts.${config.networking.hostName};
    };
  };
  config.chr.meta = {
    tldomain = "r505.de";
    hosts = {
      tower = {
        zone = "home";
        type = "desktop";
        wg = "10.10.10.32";
      };
      x13 = {
        zone = "home";
        type = "laptop";
        wg = "10.10.10.31";
      };
      air13 = {
        zone = "home";
        wg = "10.10.10.10";
      };
      oca = {
        ipv4 = "130.162.232.230";
        wg = "10.10.10.20";
      };
      oc1 = {
        ipv4 = "130.162.235.43";
        wg = "10.10.10.21";
      };
      oc2 = {
        ipv4 = "158.101.166.142";
        wg = "10.10.10.22";
      };
    };
  };
}
