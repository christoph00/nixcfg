{
  inputs',
  lib,
  ...
}: {
  programs.chromium = {
    enable = true;
    package = inputs'.unfree.legacyPackages.vivaldi.override {
      proprietaryCodecs = true;
      enableWidevine = true;
    };
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
      {id = "jofbglonpbndadajbafmmaklbfbkggpo";} # Bing Chat for all Browers
    ];
    commandLineArgs = [
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      # "--force-dark-mode"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
      "--disable-features=UseChromeOSDirectVideoDecoder"
      "--use-vulkan"
      "--ozone-platform-hint=auto"
      "--enable-hardware-overlays"
      # "--password-store=gnome"
      # "--gtk-version=4"
    ];
  };
}
