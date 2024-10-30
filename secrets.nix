let

  christoph_tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHqEQOgEdi3e8uPWqE2nqzyiKC9Y792C5tNKco6lz4o";
  christoph_x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoppzmns1lt6TT2otVKHn1ErtUn5pNzJXbViaYymrLn";
  christoph_oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXvfa+PwkdnF9PIOT0T3qb42Kduklar59uog8ugm2fx";

  # Hosts
  csrv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkYJjXoEofN3Nb/b9Dxsc0+J2S5fUU7fZOs6hqZCvGT";
  lsrv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGzR8Ju+yw7yBpNlwIo74Ov0bidgrqRJjL/xi64I0qzu";
  tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9QsDiXxdI910DdpiwX7FnsTYASANTK7Xs/kM8hWCxN";
  oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANvJNo6Vo6IaTx7ND2fBILxrpswvprOvFRCb+RYF1El";
  oc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxEMuue30m1zhq/03TMgJrj1t+8hRudPPpWMM3/5o9A";
  oc2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8HbngVMLrM3sfnr8tz3moOlahHFgA0BliQREX6toe";
  x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+dCB8RPOgkaXoRT6FnUIft5axZ0BF41wAzYPXJjRkR";

  servers = [
    csrv
    lsrv
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
  "secrets/vector.env".publicKeys = all;

}
