{ ... }:
{
  imports = [
    # ./homeassistant
    ./dnscrypt.nix
    ./media.nix
    ./neovim-server.nix
    # ./mqtt.nix
    # ./nas.nix
    # ./office-server.nix
    ./headscale.nix
    ./n8n.nix
    ./open-webui.nix
    ./audio.nix
    ./audiobookshelf.nix
    ./actual.nix
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
    ./mcp-proxy.nix
    # ./litellm.nix
  ];
}
