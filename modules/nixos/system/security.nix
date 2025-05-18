{
  lib,
  flake,
  config,
  ...
}:
let
  inherit (lib) mkForce;

in
{
  config = {

    security = {
      sudo-rs = {
        enable = true;
        execWheelOnly = true;
        wheelNeedsPassword = false;

      };
      sudo.enable = mkForce false;

      polkit.enable = true;

      protectKernelImage = true;
      allowSimultaneousMultithreading = true;
      allowUserNamespaces = true;

      pam.loginLimits = [
        {
          domain = "*";
          item = "nofile";
          type = "-";
          value = "65536";
        }
      ];

    };

  };
}
