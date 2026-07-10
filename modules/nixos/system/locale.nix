{ lib, ... }: {
  config = {
    i18n.defaultLocale = lib.mkDefault "de_DE.UTF-8";
  };
}
