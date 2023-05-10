{
  config,
  pkgs,
  ...
}: {
  users.users.nina = {
    description = "Nina";
    isNormalUser = true;
    createHome = true;
    shell = pkgs.bash;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
      "uinput"
      "dbus"
      "adbusers"
      "lp"
      "scanner"
      "sound"
      "media"
      "adbusers"
    ];

    passwordFile = config.age.secrets.nina-password.path;
  };
}
