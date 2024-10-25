{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  extension = shortId: uuid: {
    name = uuid;
    value = {
      install_url = "file:///${
        inputs.firefox-addons.packages.${pkgs.system}.${shortId}
      }/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${uuid}.xpi";
      installation_mode = "force_installed";
      default_area = "menupanel";
    };
  };
in
{
 # "*".installation_mode = "blocked";
}
// lib.listToAttrs [
  (extension "dictionary-german" "de-DE@dictionaries.addons.mozilla.org")
  (extension "ublock-origin" "uBlock0@raymondhill.net")
  (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
  (extension "passbolt" "passbolt@passbolt.com")
]
