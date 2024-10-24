{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib
, # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs
, # You also have access to your flake's inputs.
  config
, inputs
, ...
}:

with builtins;
with lib;
with lib.internal;

let
  cfg = config.internal.graphical.apps.firefox;


in
{

  options.internal.graphical.apps.firefox = {
    enable = mkBoolOpt config.internal.isGraphical "Enable Firefox.";
  };

  config = mkIf cfg.enable {

    environment.systemPackages =
      let
        wrapped = inputs.wrapper-manager.lib.build {
          inherit pkgs;
          modules = [
            {
              wrappers = {
                firefox = {
                  basePackage = pkgs.wrapFirefox pkgs.firefox-unwrapped {
                    extraPolicies.ExtensionSettings = import ./extensions.nix { inherit inputs pkgs lib; };
                    extraPrefs = import ./preferences.nix { inherit inputs; };
                  };

                };

              };
            }
          ];
        };
      in
      [
        wrapped
      ];

  };

}
