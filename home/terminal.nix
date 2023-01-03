{
  pkgs,
  inputs,
  system,
  ...
}: {
  home.packages = with pkgs; [
    ripgrep
    htop
    alejandra
  ];

  programs = {
    bat.enable = true;
    autojump.enable = false;
    fzf.enable = true;
    jq.enable = true;
  };
}
