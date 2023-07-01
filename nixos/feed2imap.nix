{config, ...}:{

  age.secrets.feed2imap-config.file = ../secrets/feed2imap.yml;

  services.feed2imap = {
    enable = true;
    configFile = config.age.secrets.feed2imap-config.path;
  };
}