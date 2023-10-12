{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.user;
in {
  options.chr.user = with types; {
    name = mkOpt str "christoph" "The name to use for the user account.";
    fullName = mkOpt str "christoph" "The full name of the user.";
    email = mkOpt str "christoph@asche.co" "The email of the user.";
    hashedPasswordFile =
      mkOpt str config.age.secrets.user-password.path
      "Hashed Password File";
    icon =
      mkOpt (nullOr package) defaultIcon
      "The profile picture to use for the user.";
    extraGroups = mkOpt (listOf str) [] "Groups for the user to be assigned.";
    authorizedKeys = mkOpt (listOf str) [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX christoph@air13"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@tower"
    ] "Authorized Keys.";

    extraOptions =
      mkOpt attrs {}
      (mdDoc "Extra options passed to `users.users.<name>`.");
  };

  config = {
    age.secrets.user-password.file = ../../../secrets/christoph-password.age;

    security.sudo.wheelNeedsPassword = false;
    programs.fuse.userAllowOther = true;
    users.mutableUsers = false;

    users.users.${cfg.name} =
      {
        isNormalUser = true;

        inherit (cfg) name hashedPasswordFile;

        home = "/home/${cfg.name}";
        group = "users";

        shell = pkgs.bash;

        uid = 1000;

        extraGroups = ["wheel" "lp" "input" "dbus"] ++ cfg.extraGroups;

        openssh.authorizedKeys.keys = [] ++ cfg.authorizedKeys;
      }
      // cfg.extraOptions;
  };
}
