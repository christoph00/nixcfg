{
  config,
  pkgs,
  ...
}: {
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      #{id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
      {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
      {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
      }
    ];
  };

  nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";

  home.persistence = {
    "/nix/persist/home/christoph".directories = [".config/chromium/Default" ".config/BraveSoftware/Brave-Browser/Default"];
  };
}
