let
  # Users
  christoph_air13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX christoph@air13";
  christoph_tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8 christoph@tower";
  christoph_x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5KqxXvpZ+R7/GYx99+W0rPHatXKf6/pG6rZ8z81/f6 christoph@x13";

  # Hosts
  air13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJaQ1qn7oju1z6X2mumCSg+bsTCNlgzE5KahvO2BxKtg";
  futro = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkYJjXoEofN3Nb/b9Dxsc0+J2S5fUU7fZOs6hqZCvGT";
  cube = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBI4yh7tPt63/eYKBxZPlVaOeNnYcxgVXLiqHh1uPSLD";
  tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH5CLg7gUc4TAu49l7wlRGS4v9JXY3CR0IJUQIlrQ4bl";
  oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOEtatTimOZTGlJlSaoTFzDsxcccueIWGvTDs25+6r3 ";
  oc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxEMuue30m1zhq/03TMgJrj1t+8hRudPPpWMM3/5o9A";
  oc2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8HbngVMLrM3sfnr8tz3moOlahHFgA0BliQREX6toe";
  star = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICQRi4HsYX2Mbv7SPPpzPp/uiNQlx8bRin2Z+UN5K0qC";
  x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+DRHaQYXS4jLpb6TQ72zP3prgkcb2X0YVGIXtUCHUY";
  turtle = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGs1EldBV90G7uqmUgewt+4Lfcot9WSgDBpZZ4c5184E";
in {
  #  "secrets/cachix".publicKeys = [christoph_air13 air13 futro tower oca cube star];
  #  "secrets/tailscale-preauthkey".publicKeys = [christoph_air13 christoph_tower air13 futro cube tower oca oc1 oc2 star];
  #  "secrets/tailscale-tsnsrv".publicKeys = [christoph_air13 christoph_tower air13 futro cube tower oca oc1 oc2 star];

  #  "secrets/cf-acme".publicKeys = [christoph_air13 futro cube oca oc1 oc2 tower star];
  #  "secrets/cf-dyndns".publicKeys = [christoph_air13 futro tower];
  #  "secrets/futro-cf".publicKeys = [christoph_air13 futro];
  #  "secrets/immich-env".publicKeys = [christoph_air13 futro];
  #  "secrets/immich-db-password".publicKeys = [christoph_air13 futro];

  "secrets/cf-tunnel-futro".publicKeys = [christoph_tower christoph_x13 futro];
  "secrets/cf-tunnel-air13".publicKeys = [christoph_tower christoph_x13 air13];

  #  "secrets/feed2imap.yml".publicKeys = [christoph_air13 oc1];

  "secrets/netbird.env".publicKeys = [christoph_air13 christoph_tower christoph_x13 x13 futro air13 tower oca oc1 oc2 cube star turtle];

  "secrets/ha-serviceaccount".publicKeys = [christoph_air13 christoph_tower futro air13 christoph_x13];
  "secrets/ha-secrets.yaml".publicKeys = [christoph_air13 christoph_tower futro air13 christoph_x13];
  "secrets/christoph-password.age".publicKeys = [christoph_air13 christoph_tower christoph_x13 futro air13 tower oca oc1 oc2 cube star x13 turtle];
  #  "secrets/wayvnc-key".publicKeys = [christoph_air13 tower christoph_tower];
  #  "secrets/wayvnc-cert".publicKeys = [christoph_air13 tower christoph_tower];
  #  "secrets/rclone.conf".publicKeys = [christoph_air13 tower air13 futro oca oc1 oc2 christoph_tower star];
  #  "secrets/traefik.env".publicKeys = [christoph_air13 oca oc1 oc2 futro cube];
  #  "secrets/agent-key".publicKeys = [christoph_air13 futro];
  #  "secrets/nd-key".publicKeys = [christoph_air13 christoph_tower futro air13 tower oca oc1 oc2];
  #  "secrets/rclone-nd.conf".publicKeys = [christoph_air13 futro air13 tower oca oc1 oc2];
  #  "secrets/pia.env".publicKeys = [christoph_air13 star];
  #  "secrets/pia.crt".publicKeys = [christoph_air13 star];
  #  "secrets/nc-admin-pass".publicKeys = [christoph_air13 star futro oca tower christoph_tower];
  "secrets/yarr-auth".publicKeys = [christoph_x13 futro];
  "secrets/grafana-password".publicKeys = [christoph_x13 futro x13 tower air13 oca oc1 oc2];
  "secrets/vaultwarden.env".publicKeys = [christoph_x13 futro];
  "secrets/paperless-token.env".publicKeys = [christoph_x13 futro];
}
