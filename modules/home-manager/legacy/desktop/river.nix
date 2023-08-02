{
  pkgs,
  config,
  ...
}: {
  home.packages = [pkgs.river pkgs.rivercarro];
}
