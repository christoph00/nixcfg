{
  pkgs,
  config,
  lib,
  ...
}: let
  configFile = pkgs.writeText "geary.ini" (lib.generators.toINI {} {
    Account = {
      label = "";
      ordinal = 6;
      prefetch_days = 30;
      save_drafts = true;
      save_sent = true;
      sender_mailboxes = "Christoph Asche <christoph@asche.co>;";
      service_provider = "other";
      signature = builtins.replaceStrings ["\n"] ["\\n"] ''
        --
      '';
      use_signature = false;
    };
    Folders = {
      archive_folder = "Archive";
      drafts_folder = "Drafts";
      sent_folder = "Sent";
      junk_folder = "Ungewünscht";
      trash_folder = "Trash";
    };
    Incoming = {
      credentials = "custom";
      host = "mail.asche.co";
      login = "christoph@asche.co";
      port = 993;
      remember_password = true;
      transport_security = "transport";
    };
    Metadata = {
      status = "enabled";
      version = 1;
    };
    Outgoing = {
      credentials = "use-incoming";
      host = "mail.asche.co";
      port = 587;
      remember_password = true;
      transport_security = "start-tls";
    };
  });
in {
  # xdg.configFile."geary/user-style.css".text = ''
  #   *, html, body, body.plain div, body.plain a, body.plain p, body.plain span {
  #     background: ${colors.base00} !important;
  #     color: ${colors.base05} !important;
  #     font-family: '${config.fontProfiles.regular.family}', monospace !important;
  #   }
  #   *, html, body {
  #     font-size: 12pt;
  #   }
  # '';
  xdg.configFile."geary/account_01/geary.ini".source = configFile;

  home.persistence = {
    "/persist/home/christoph".directories = [".local/share/geary/account_01"];
  };
}
