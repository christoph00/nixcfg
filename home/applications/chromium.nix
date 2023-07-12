{pkgs, ...}: {
  programs.chromium = {
    enable = true;
    package = pkgs.microsoft-edge-dev.overrideAttrs (old: {
      nativeBuildInputs = [pkgs.makeWrapper];
      postFixup = ''
        wrapProgram $out/opt/microsoft/msedge-dev/microsoft-edge \
          -set LD_LIBRARY_PATH ${pkgs.wayland}/lib \
          --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations,VaapiVideoDecoder,VaapiVideoEncoder --gtk-version=4 --password-store=gnome --use-vulkan --enable-zero-copy --ignore-gpu-blocklist --enable-gpu-rasterization}}"
      '';
    });
    extensions = [
      {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
      # {id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
      {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
      {
        id = "dcpihecpambacapedldabdbpakmachpb";
        updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
      }
      {id = "pmcmeagblkinmogikoikkdjiligflglb";} # Privacy Redirect
      {id = "hfmolcaikbnbminafcmeiejglbeelilh";} # CNL Decryptor
      # {id = "jofbglonpbndadajbafmmaklbfbkggpo";} # Bing Chat for all Browers
    ];
    # commandLineArgs = [
    #   "--ignore-gpu-blocklist"
    #   "--enable-gpu-rasterization"
    #   "--enable-zero-copy"
    #   "--force-dark-mode"
    #   "--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
    #   "--disable-features=UseChromeOSDirectVideoDecoder"
    #   "--use-vulkan"
    #   "--ozone-platform-hint=auto"
    #   "--enable-hardware-overlays"
    #   "--password-store=gnome"
    #   "--gtk-version=4"
    # ];
  };
}
