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
      formatter.alejandra = {
        command = "${pkgs.alejandra}/bin/alejandra";
        includes = ["*.nix"];
      };
      indent-guides = {
        render = true;
        character = "┊";
      };

      keys.normal = {
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
        esc = ["collapse_selection" "keep_primary_selection"];
      };
    };
  };
}
