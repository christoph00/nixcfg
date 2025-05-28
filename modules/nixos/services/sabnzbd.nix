{config, lib, ...}:
let
  inherit (lib) mkIf;
in {
  config = mkIf config.services.sabnzbd.enable {
    sys.state.directories = ["/var/lib/sabnzbd"];
    services.sabnzbd= {
      openFirewall = true;
      user = "christoph";
      group ="media";
    };

  };
}
