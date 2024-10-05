{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  # All other arguments come from the module system.
  config
, ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.graphical.apps.misc;
  ignis = pkgs.writers.writePython3Bin "ignis" { libraries = [ pkgs.internal.ignis ]; } ''
    if __name__ == "__main__":
        from ignis.main import main
        main()
  '';


in
{

  options.internal.graphical.apps.misc = {
    enable = mkBoolOpt config.internal.isGraphical "Enable the misc desktop apps.";
  };

  config = mkIf cfg.enable {

    environment.systemPackages = [
      pkgs.zen-browser
      pkgs.brave
      pkgs.zed-editor
      # pkgs.vivaldi
      pkgs.vscode
      pkgs.kitty
      # pkgs.foot
      pkgs.anyrun
      pkgs.moonlight-qt
      pkgs.floorp
      # pkgs.firefox
      pkgs.librewolf
      # pkgs.vesktop
      # pkgs.masterpdfeditor
      pkgs.libreoffice-fresh
      pkgs.geary
      pkgs.rio
    ];

  };

}
