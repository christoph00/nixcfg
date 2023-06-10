let
  # Users
  christoph_air13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX christoph@air13";
  christoph_tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@tower";

  # Hosts
  air13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaQ1qn7oju1z6X2mumCSg+bsTCNlgzE5KahvO2BxKtg";
  futro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkYJjXoEofN3Nb/b9Dxsc0+J2S5fUU7fZOs6hqZCvGT";
  cube = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBI4yh7tPt63/eYKBxZPlVaOeNnYcxgVXLiqHh1uPSLD";
  tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH5CLg7gUc4TAu49l7wlRGS4v9JXY3CR0IJUQIlrQ4bl";
  oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGoZYVHRKCEs5lRYEIr1OgkydoPiGpVaUGStAIYakXgI";
  oc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxEMuue30m1zhq/03TMgJrj1t+8hRudPPpWMM3/5o9A";
  oc2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8HbngVMLrM3sfnr8tz3moOlahHFgA0BliQREX6toe";
  star = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQRi4HsYX2Mbv7SPPpzPp/uiNQlx8bRin2Z+UN5K0qC";
in {
  "secrets/cachix".publicKeys = [christoph_air13 air13 futro tower oca cube star];
  "secrets/tailscale-preauthkey".publicKeys = [christoph_air13 christoph_tower air13 futro cube tower oca oc1 oc2 star];
  "secrets/cf-acme".publicKeys = [christoph_air13 futro cube oca oc1 oc2 tower star];
  "secrets/cf-dyndns".publicKeys = [christoph_air13 futro tower];
  "secrets/futro-cf".publicKeys = [christoph_air13 futro];
  "secrets/immich-env".publicKeys = [christoph_air13 futro];
  "secrets/immich-db-password".publicKeys = [christoph_air13 futro];

  "secrets/ha-serviceaccount".publicKeys = [christoph_air13 futro];
  "secrets/ha-secrets.yaml".publicKeys = [christoph_air13 futro];
  "secrets/christoph-password.age".publicKeys = [christoph_air13 futro air13 tower oca oc1 oc2 cube star];
  "secrets/wayvnc-key".publicKeys = [christoph_air13 tower christoph_tower];
  "secrets/wayvnc-cert".publicKeys = [christoph_air13 tower christoph_tower];
  "secrets/rclone.conf".publicKeys = [christoph_air13 tower air13 futro oca oc1 oc2 christoph_tower star];
  "secrets/traefik.env".publicKeys = [christoph_air13 oca oc1 oc2 futro cube];
  "secrets/agent-key".publicKeys = [christoph_air13 futro];
  "secrets/nd-key".publicKeys = [christoph_air13 christoph_tower futro air13 tower oca oc1 oc2];
  "secrets/rclone-nd.conf".publicKeys = [christoph_air13 christoph_air13 futro air13 tower oca oc1 oc2];
  "secrets/pia.env".publicKeys = [christoph_air13 star];
  "secrets/pia.crt".publicKeys = [christoph_air13 star];
  "secrets/nc-admin-pass".publicKeys = [christoph_air13 star futro oca tower christoph_tower];
}
