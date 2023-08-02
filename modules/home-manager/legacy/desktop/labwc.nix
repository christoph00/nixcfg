{
  config,
  pkgs,
  ...
}: {
  home.packages = [pkgs.labwc];
}
