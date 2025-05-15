{
  flake,
  lib,
  pkgs,
  ...
}:
let
  inherit (flake.lib) nodefault;
  inherit (lib) mkDefault;

in
{

  documentation = {
    enable = mkDefault false;
    doc = nodefault;
    info = nodefault;
    man = nodefault;
    nixos = nodefault;
  };

  environment = {
    defaultPackages = mkDefault [ ];
    stub-ld = nodefault;
  };

  programs = {
    less.lessopen = mkDefault null;
    command-not-found = nodefault;
    git.package = lib.mkDefault pkgs.gitMinimal;
  };

  boot.enableContainers = mkDefault false;

  services = {
    logrotate = nodefault;
    udisks2 = nodefault;
    lvm.enable = nodefault;
  };

  xdg = {
    autostart = nodefault;
    icons = nodefault;
    mime = nodefault;
    sounds = nodefault;
    menus = nodefault;
  };

}
