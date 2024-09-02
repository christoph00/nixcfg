{
  options,
  config,
  pkgs,
  lib,
  namespace,
  ...
}:
with lib;
with lib.interal;
let
  cfg = config.internal.shell;

   v3 = with pkgs.pkgsx86_64_v3-core; [
    curl
    bash
    elfutils
    diffutils
    debugedit
    file
    less
    which
  ];
in
{
  options.internal.shell = with types; {
    enable = mkBoolOpt true "Whether or not to configure shell config.";
  };

  config = mkIf cfg.enable { 

    environment.systemPackages = with pkgs; [
      fzf
    ] ++ mkIf config.internal.isV3 v3
    
   };
}
