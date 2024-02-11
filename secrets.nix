let
  # Users
  christoph_air13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBCs+VL1FAip0JZ2wWnop9lUZHcs30mibUwwrMJpfAX";
  christoph_tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8";
  christoph_x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5KqxXvpZ+R7/GYx99+W0rPHatXKf6/pG6rZ8z81/f6";

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

  all = [air13 futro cube tower oca oc1 oc2 star x13 turtle];
  servers = [air13 futro oca oc1 oc2];
  desktops = [tower x13];
  users = [christoph_tower christoph_x13];
in {
  "secrets/cf-tunnel-futro".publicKeys = [futro] ++ users;
  "secrets/cf-tunnel-air13".publicKeys = [air13] ++ users;
  "secrets/cf-tunnel-oca".publicKeys = [oca] ++ users;

  "secrets/netbird.env".publicKeys = all ++ users;
  "secrets/tailscale-auth-key".publicKeys = all ++ users;

  "secrets/ha-serviceaccount".publicKeys = [futro air13] ++ users;
  "secrets/ha-secrets.yaml".publicKeys = [futro air13] ++ users;
  "secrets/christoph-password.age".publicKeys = all ++ users;

  "secrets/yarr-auth".publicKeys = [futro air13] ++ users;
  "secrets/grafana-password".publicKeys = all ++ users;
  "secrets/vaultwarden.env".publicKeys = [futro air13] ++ users;
  "secrets/paperless-token.env".publicKeys = [futro air13] ++ users;
  "secrets/caddy.env".publicKeys = servers ++ users;
}
