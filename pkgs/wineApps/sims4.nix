{pkgs, ...}: let
  bin = pkgs.wrapWine {
    name = "sims4";
    is64bits = true;
    executable = "~/Games/Sims4/Game/Bin/TS4_x64.exe";
    prefix = "~/Games/Sims4/PFX";
    tricks = ["corefonts" "dxvk"];
    gamescope = true;
  };
in
  bin
