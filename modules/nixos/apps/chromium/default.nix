{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.apps.chromium;
in {
  options.chr.apps.chromium = with types; {
    enable = mkBoolOpt config.chr.desktop.enable "Whether or not to enable Chromium.";
  };

  config = mkIf cfg.enable {
    chr.home = {
      extraOptions = {
        home.packages = [pkgs.widevine-cdm];
        programs.chromium = {
          enable = true;
          package = pkgs.chr.thorium;
          extensions = [
            # {id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";} # Ublock Origin
            #{id = "jhnleheckmknfcgijgkadoemagpecfol";} # Auto-Tab-Discard
            {id = "nngceckbapebfimnlniiiahkandclblb";} # Bitwarden
            {
              id = "dcpihecpambacapedldabdbpakmachpb";
              updateUrl = "https://raw.githubusercontent.com/iamadamdev/bypass-paywalls-chrome/master/updates.xml";
            }
            #{id = "pmcmeagblkinmogikoikkdjiligflglb";} # Privacy Redirect
            #{id = "hfmolcaikbnbminafcmeiejglbeelilh";} # CNL Decryptor
            {id = "hceobhjokpdbogjkplmfjeomkeckkngi";} # New Bing Anywhere
            {id = "jinjaccalgkegednnccohejagnlnfdag";} # Violentmonkey
          ];
          commandLineArgs = [
            "--ignore-gpu-blocklist"
            "--enable-gpu-rasterization"
            "--enable-zero-copy"
            # "--force-dark-mode"
            #"--enable-features=VaapiVideoDecoder,VaapiVideoEncoder"
            "--disable-features=UseChromeOSDirectVideoDecoder"
            "--use-vulkan"
            "--ozone-platform-hint=auto"
            # "--enable-hardware-overlays"
            # "--password-store=gnome"
            "--gtk-version=4"
          ];
        };
      };
    };
  };
}
