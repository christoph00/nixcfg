{
  config,
  pkgs,
  lib,
  ...
}: {
  services.pia-vpn = {
    enable = true;
    certificateFile = config.age.secrets.pia-crt.path;
    environmentFile = config.age.secrets.pia-env.path;
  };

  age.secrets.pia-env.file = ../secrets/pia.env;
  age.secrets.pia-crt.file = ../secrets/pia.crt;
}
