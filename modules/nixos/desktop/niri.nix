{
  lib,
  flake,
  config,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (flake.lib) mkBoolOpt;

  niriswitch = pkgs.writeShellScriptBin "niriswitch" ''
    windows=$(${pkgs.niri}/bin/niri msg -j windows)
    ${pkgs.niri}/bin/niri msg action focus-window --id \
      $(echo "$windows" | 
        ${pkgs.jq}/bin/jq ".[$(echo "$windows" | ${pkgs.jq}/bin/jq -r 'map("\(.title // .app_id)\u0000icon\u001f\(.app_id)") | .[]' | ${pkgs.fuzzel}/bin/fuzzel -d --index)].id"
      )
  '';
in
{

  options.desktop.niri = {
    enable = mkBoolOpt config.desktop.enable;
  };

  config = mkIf config.desktop.niri.enable {

    programs.niri.enable = true;

    xdg.portal.config.niri = {
      default = "gtk;gnome";
    };

    home.packages = with pkgs; [
      xwayland-satellite
      brightnessctl
      fuzzel
      ghostty
    ];

    # hjem.users.christoph.files.".config/niri/config.kdl".text = builtins.readFile ./niri.kdl;

    programs.uwsm.waylandCompositors = {
      niri = {
        prettyName = "Niri";
        comment = "A scrollable-tiling Wayland compositor.";
        binPath = "${pkgs.niri}/bin/niri";
      };
    };

  };

}
