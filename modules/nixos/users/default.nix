{
  config,
  lib,
  flake,
  inputs,
  pkgs,
  ...
}:
let
  inherit (lib) types mkDefault mkIf;
  inherit (flake.lib) mkStrOpt mkOpt mkBoolOpt;
  cfg = config.user;
in
{
  imports = [ (lib.modules.mkAliasOptionModule [ "home" ] [ "hjem" "users" "${cfg.name}" ]) ];
  options = {
    user = with types; {
      name = mkStrOpt "christoph";
      fullName = mkStrOpt "Christoph";
      passwordFile = mkOpt (nullOr path) null;
      email = mkOpt str "christoph@asche.co";
      extraGroups = mkOpt (listOf str) [ ];
      extraOptions = mkOpt attrs { };
      hjem = mkBoolOpt true;
    };
  };

  config = {
    age.secrets.user_christoph_pw.file = "${flake}/secrets/user_christoph_pw";

    user.passwordFile = mkIf (!config.host.bootstrap) config.age.secrets.user_christoph_pw.path;

    users.users.${cfg.name} = {
      isNormalUser = true;

      inherit (cfg) name;

      hashedPasswordFile = cfg.passwordFile;
      hashedPassword = mkIf config.host.bootstrap "$y$j9T$QgTeWgADVMseXf1yfCPNN1$FANADtOZcSiLPuNg9SJbdVKWPvLokK7MfVa4iNvJZP4";

      home = "/home/${cfg.name}";
      group = "users";

      shell = pkgs.zsh;

      uid = 1000;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1MrbLLO4xfy0qns7diUDklWd8LthvvdKIMdydKNb9f christoph@oca"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwrR18ub6bgzehbzGzwFu4gBXPuBfkXCYLlqS9Qbal2 christoph@x13"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJznPNQqLgyHNL2Cxbtx3RO6BncMpC1Bpyae/edKW7oH christoph@tower"

        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBMM61ElzdrJV9KqIcktRE52m/TGZ4fWbbiddNcEj8s/" # w
      ];

      linger = mkDefault false;

      extraGroups = [
        "wheel"
        "audio"
        "sound"
        "video"
        "networkmanager"
        "input"
        "tty"
        "seat"
        "render"
        "dialout"
        "media"
      ]
      ++ cfg.extraGroups;
    }
    // cfg.extraOptions;

    users.groups.media = {
      gid = 1101;
    };

    hjem = mkIf cfg.hjem {
      clobberByDefault = true;
      extraModules = [
        inputs.hjem-rum.hjemModules.default
      ];
      users.${cfg.name} = {
        enable = true;
        directory = "/home/${cfg.name}";
        user = "${cfg.name}";
      };
    };
  };
}
