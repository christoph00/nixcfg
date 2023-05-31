{
  config,
  pkgs,
  lib,
  ...
}: {
   services.pia-vpn = {
      enable = true;
      certificateFile = "ca.rsa.4096.crt";
      environmentFile = "pia.env";
    };
}
