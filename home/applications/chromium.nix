{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    package = pkgs.ungoogled-chromium;
    extensions = [
<<<<<<< HEAD
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
      # {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
||||||| parent of fade8c4 ()
      # {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
      # {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
=======
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
        {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
>>>>>>> fade8c4 ()
      {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
      }
      {id = "pmcmeagblkinmogikoikkdjiligflglb";} # Privacy Redirect
      {id = "hfmolcaikbnbminafcmeiejglbeelilh";} # CNL Decryptor
      {id = "jofbglonpbndadajbafmmaklbfbkggpo";} # Bing Chat for all Browers
    ];
    defaultSearchProviderSuggestURL = [
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--force-dark-mode"
      "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
      "--disable-features=UseChromeOSDirectVideoDecoder"
      "--use-vulkan"
      "--ozone-platform-hint=auto"
      "--enable-hardware-overlays"
      "--password-store=gnome"
      "--gtk-version=4"
    ];
  };
}
