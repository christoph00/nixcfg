{ ... }:
{
  imports = [
    # ./homeassistant
    # ./media.nix
    # ./mqtt.nix
    # ./nas.nix
    # ./office-server.nix
    # ./searx.nix
    ./sshd.nix
    # ./webserver.nix
    ./rclone.nix
    ./actions-runner.nix
  ];
}
