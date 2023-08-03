{
  self,
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.anyrun.homeManagerModules.default
    ./cli
    ./desktop
  ];

  config = {
    # reload system units when changing configs
    systemd.user.startServices = lib.mkDefault "sd-switch"; # or "legacy" if "sd-switch" breaks again

    home = {
      username = "christoph";
      homeDirectory = "/home/christoph";

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = lib.mkDefault "23.05";
      extraOutputsToInstall = ["doc" "devdoc"];
    };

    manual = {
      html.enable = false;
      json.enable = false;
      manpages.enable = true;
    };

    programs.home-manager.enable = true;
  };
}
