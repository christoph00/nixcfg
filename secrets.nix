let
  # Users
  christoph_air13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX christoph@air13";
  christoph_tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@tower";

  # Hosts
  air13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaQ1qn7oju1z6X2mumCSg+bsTCNlgzE5KahvO2BxKtg";
  futro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkYJjXoEofN3Nb/b9Dxsc0+J2S5fUU7fZOs6hqZCvGT";
  tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH5CLg7gUc4TAu49l7wlRGS4v9JXY3CR0IJUQIlrQ4bl";
  oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoZYVHRKCEs5lRYEIr1OgkydoPiGpVaUGStAIYakXgI";
  oc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGeJMB9F6JIthu6pltQqAH4FexyNeP+haAkEy5juJrdC";
in {
  "secrets/cachix".publicKeys = [christoph_air13 air13 futro tower oca oc1];
  "secrets/tailscale-preauthkey".publicKeys = [christoph_air13 air13 futro tower oca oc1];
  "secrets/cf-acme".publicKeys = [christoph_air13 futro oca oc1 tower];
  "secrets/futro-cf".publicKeys = [christoph_air13 futro];
  "secrets/ha-serviceaccount".publicKeys = [christoph_air13 futro];
  "secrets/ha-secrets.yaml".publicKeys = [christoph_air13 futro];
  "secrets/christoph-password.age".publicKeys = [christoph_air13 futro air13 tower oca oc1];
  "secrets/wayvnc-key".publicKeys = [christoph_air13 tower christoph_tower];
  "secrets/wayvnc-cert".publicKeys = [christoph_air13 tower christoph_tower];
}
