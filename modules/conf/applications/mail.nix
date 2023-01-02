{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.conf.applications.email;
in {
  options.conf.applications.email.enable = lib.mkEnableOption "email";
  config.home-manager.users.${config.conf.users.user} = lib.mkIf cfg.enable {
    programs.mbsync.enable = true;
    programs.msmtp.enable = true;
    programs.notmuch = {
      enable = true;
      hooks = {
        preNew = "mbsync --all";
      };
    };
    accounts.email = {
      accounts.main = {
        address = "christoph@asche.co";
        imap.host = "mail.asche.co";
        mbsync = {
          enable = true;
          create = "maildir";
        };
        msmtp.enable = true;
        notmuch.enable = true;
        primary = true;
        realName = "Christoph Asche";
        signature = {
          text = ''
            Christoph Asche

          '';
          showSignature = "append";
        };
        passwordCommand = "mail-password";
        smtp = {
          host = "mail.asche.co";
        };
        userName = "christoph@asche.co";
      };
    };
  };
}
