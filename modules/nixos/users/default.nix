{
  config,
  lib,
  flake,
  ...
}:
let
  inherit (lib) types mkDefault mkIf;
  inherit (flake.lib) mkStrOpt mkOpt mkBoolOpt;
  cfg = config.user;
in
{
  options.user = with types; {
    name = mkStrOpt "christoph";
    fullName = mkStrOpt "Christoph";
    passwordFile = mkOpt (nullOr path) null;
    email = mkOpt str "christoph@asche.co";
    extraGroups = mkOpt (listOf str) [ ];
    extraOptions = mkOpt attrs { };
    enableHM = mkBoolOpt false;
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

      uid = 1000;

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXvfa+PwkdnF9PIOT0T3qb42Kduklar59uog8ugm2fx christoph@oca"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFmHJIHJYMl/0awPcEeftLSxDKGVWmN0jhYPQ5hCINxD christoph@wrk"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHqEQOgEdi3e8uPWqE2nqzyiKC9Y792C5tNKco6lz4o christoph@tower"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoppzmns1lt6TT2otVKHn1ErtUn5pNzJXbViaYymrLn christoph@x13"

        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDrBVHoPvd10kDl4WjgUqWh3PdMzrDRXauG3zkfYocjt n8n" # TODO: add to agent user
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
      ] ++ cfg.extraGroups;
    } // cfg.extraOptions;
  };
}
