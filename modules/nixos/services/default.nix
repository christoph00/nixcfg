{ ... }:
{
  imports = [
    ./actions-runner.nix
    ./agentgateway.nix
    ./altmount.nix
    ./audio.nix
    ./audiobookshelf.nix
    ./actual.nix
    ./beszel-agent.nix
    ./clawdbot.nix
    ./code-tunnel.nix
    ./dnscrypt.nix
    ./fail2ban.nix
    ./headscale.nix
    ./homeassistant
    ./karakeep.nix
    ./mail-server.nix
    ./media.nix
    ./mcp-proxy.nix
    ./mqtt.nix
    ./n8n.nix
    ./neovim-server.nix
    ./open-webui.nix
    ./pinchflat.nix
    ./proxy.nix
    ./printserver.nix
    ./rclone.nix
    ./rssbridge.nix
    ./sabnzbd.nix
    ./searx.nix
    ./sshd.nix
    ./webserver.nix
    # ./nas.nix
    # ./office-server.nix
    # ./vector.nix
    ./postgresql.nix
    ./litellm.nix
  ];
}
