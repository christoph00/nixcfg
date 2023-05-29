{
  config,
  pkgs,
  # inputs,
  # lib,
  ...
}: {
  programs.helix = {
    enable = true;
    # package = helixUnstable;
    languages = [
      {
        name = "bash";
        language-server = {
          command = "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server";
          args = ["start"];
        };
        auto-format = true;
      }
      {
        name = "nix";
        language-server = {command = "${pkgs.nil}/bin/nil";};
        config.nil.formatting.command = ["${pkgs.alejandra}/bin/alejandra" "-q"];
        auto-format = true;
      }
    ];
  };
}
