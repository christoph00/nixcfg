let

  christoph_tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICRlMoMsGWPbUR9nC0XavzLmcolpF8hRbvQYALJQNMg8";
  christoph_x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC5KqxXvpZ+R7/GYx99+W0rPHatXKf6/pG6rZ8z81/f6";
  christoph_oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXvfa+PwkdnF9PIOT0T3qb42Kduklar59uog8ugm2fx";

  # Hosts
  csrv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkYJjXoEofN3Nb/b9Dxsc0+J2S5fUU7fZOs6hqZCvGT";
  tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH5CLg7gUc4TAu49l7wlRGS4v9JXY3CR0IJUQIlrQ4bl";
  oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANvJNo6Vo6IaTx7ND2fBILxrpswvprOvFRCb+RYF1El";
  oc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxEMuue30m1zhq/03TMgJrj1t+8hRudPPpWMM3/5o9A";
  oc2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8HbngVMLrM3sfnr8tz3moOlahHFgA0BliQREX6toe";
  x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE+DRHaQYXS4jLpb6TQ72zP3prgkcb2X0YVGIXtUCHUY";

  servers = [
    csrv
    oca
    oc1
    oc2
  ];
  desktops = [
    tower
    x13
  ];
  all = servers ++ desktops ++ users;
  users = [
    christoph_tower
    christoph_x13
    christoph_oca
  ];
in
{

  "secrets/tailscale-auth-key".publicKeys = all;

}
