{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  services.code-server = {
    enable = true;
    user = "christoph";
    group = "users";
    auth = mkDefault "none";
    host = mkDefault "0.0.0.0";
    extraPackages = [pkgs.nil pkgs.alejandra];
  };
}
