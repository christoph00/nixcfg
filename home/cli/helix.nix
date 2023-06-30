{
  config,
  pkgs,
  # inputs,
  # lib,
  ...
}: {
  programs.helix = {
    enable = true;
    settings = {
      theme = "base16_default";
    };
  };
}
