{ ... }:
{
  imports = [
    # ./homeassistant
    ./dnscrypt.nix
    ./media.nix
    # ./mqtt.nix
    # ./nas.nix
    # ./office-server.nix
    ./n8n.nix
    ./open-webui.nix
    ./mcpo.nix
    ./audio.nix
    ./audiobookshelf.nix
    ./searx.nix
    ./rssbridge.nix
    ./sshd.nix
    ./pinchflat.nix
    ./webserver.nix
    ./rclone.nix
    ./actions-runner.nix
    ./proxy.nix
    ./sabnzbd.nix
    ./agentgateway.nix
    # ./litellm.nix
  ];
}
