{
  config,
  pkgs,
  ...
}: {
  programs.chromium = {
    enable = true;
    package = pkgs.chromium;
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
      {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
      {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
      }
      {id = "pmcmeagblkinmogikoikkdjiligflglb";} # Privacy Redirect
      {id = "hfmolcaikbnbminafcmeiejglbeelilh";} # CNL Decryptor
      {id = "ncgbkkljbaojkhljombpjejedphfhdjj";} # User Agent Switcher
    ];
    commandLineArgs = [
      "--enable-features=UseOzonePlatform"
      "--ozone-platform=wayland"
      "--ignore-gpu-blocklist"
    ];
  };

  nixpkgs.config.chromium.commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";

  home.persistence = {
    "/nix/persist/home/christoph".directories = [".config/chromium/Default" ".config/BraveSoftware/Brave-Browser/Default"];
  };
}
