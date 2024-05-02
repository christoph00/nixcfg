{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.system.locale;
in
{
  options.chr.system.locale = with types; {
    enable = mkBoolOpt true "Whether or not to configure locale information.";
  };

  config = mkIf cfg.enable {
    time.timeZone = "Europe/Berlin";

    i18n.defaultLocale = "de_DE.UTF-8";

    console = {
      keyMap = mkForce "us";
    };
  };
}
