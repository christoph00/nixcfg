{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.apps.thunderbird;
  defaultSettings = {
    "privacy.donottrackheader.enabled" = true;
  };
in
{
  options.chr.apps.thunderbird = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not to enable Thunderbird.";
    extraConfig = mkOpt str "" "Extra configuration for the user profile JS file.";
    userChrome = mkOpt str "" "Extra configuration for the user chrome CSS file.";
    settings = mkOpt attrs defaultSettings "Settings to apply to the profile.";
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        programs.thunderbird = {
          enable = true;
          profiles.${config.chr.user.name} = {
            inherit (cfg) extraConfig userChrome settings;
            isDefault = true;
          };
        };
      };
    };
  };
}
