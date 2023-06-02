{
  config,
  pkgs,
  ...
}: {
  services.sftpgo = {
    enable = true;
    group = "media";
    dataDir = "/mnt/ncdata";
    webdavd.bindings = [{
      port = 8099;
      address = "0.0.0.0";
    }];
     httpd.bindings = [{
      port = 8090;
      address = "0.0.0.0";
    }];
  };
}
