{ ... }:
{
  imports = [
    # ./homeassistant
    ./dnscrypt.nix
    # ./media.nix
    # ./mqtt.nix
    # ./nas.nix
    # ./office-server.nix
    ./audio.nix
    ./audiobookshelf.nix
    ./searx.nix
    ./rssbridge.nix
    ./sshd.nix
    ./webserver.nix
    ./rclone.nix
    ./actions-runner.nix
  ];
}
