let

  christoph_tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAHqEQOgEdi3e8uPWqE2nqzyiKC9Y792C5tNKco6lz4o";
  christoph_x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHoppzmns1lt6TT2otVKHn1ErtUn5pNzJXbViaYymrLn";
  christoph_oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFXvfa+PwkdnF9PIOT0T3qb42Kduklar59uog8ugm2fx";

  # Hosts
  csrv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkYJjXoEofN3Nb/b9Dxsc0+J2S5fUU7fZOs6hqZCvGT";
  lsrv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGzR8Ju+yw7yBpNlwIo74Ov0bidgrqRJjL/xi64I0qzu";
  tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9QsDiXxdI910DdpiwX7FnsTYASANTK7Xs/kM8hWCxN";
  oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANvJNo6Vo6IaTx7ND2fBILxrpswvprOvFRCb+RYF1El";
  oc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnKU3KcDBk/lNDRDwlbewhct/tqA/xR+O2Rzd5A7V11";
  oc2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8HbngVMLrM3sfnr8tz3moOlahHFgA0BliQREX6toe";
  x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+dCB8RPOgkaXoRT6FnUIft5axZ0BF41wAzYPXJjRkR";
  star = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBF0fUs5cYSbwBcY+pqSSgiqrW+jGFJBPO+kjPz2SY1z";

  servers = [
    csrv
    lsrv
    oca
    oc1
    oc2
    star
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

  "secrets/netbird-io-setup.key".publicKeys = all;
  "secrets/tailscale-auth-key".publicKeys = all;
  "secrets/vector.env".publicKeys = all;
  "secrets/user_christoph_pw".publicKeys = all;
  "secrets/cf-api-key".publicKeys = [
    lsrv
    oca
  ] ++ users;
  "secrets/ha-secrets.age".publicKeys = [ lsrv ] ++ users;
  "secrets/ha-serviceaccount.age".publicKeys = [ lsrv ] ++ users;
  "secrets/mqtt-agent.age".publicKeys = all;
  "secrets/mqtt-ha.age".publicKeys = all; # temp
  "secrets/sftpgo.env".publicKeys = [
    oca
    lsrv
    tower
  ] ++ users;
  "secrets/rclone.conf".publicKeys = all;

  "secrets/agent-key".publicKeys = [ lsrv ] ++ users;
  "secrets/wyoming-openai.env".publicKeys = [
    lsrv
    oca
  ] ++ users;
  "secrets/aider.env".publicKeys = [
    oca
    x13
  ] ++ users;
  "secrets/searx.env".publicKeys = [
    oca
    oc1
  ] ++ users;

  "secrets/wg-oc1-key".publicKeys = [
    oc1
  ] ++ users;
  "secrets/wg-oc2-key".publicKeys = [
    oc2
  ] ++ users;
  "secrets/wg-oca-key".publicKeys = [
    oca
  ] ++ users;
  "secrets/wg-lsrv-key".publicKeys = [
    lsrv
  ] ++ users;
  "secrets/wg-csrv-key".publicKeys = [
    csrv
  ] ++ users;
  "secrets/wg-tower-key".publicKeys = [
    tower
  ] ++ users;
  "secrets/wg-x13-key".publicKeys = [
    x13
  ] ++ users;
  "secrets/wg-star-key".publicKeys = [
    star
  ] ++ users;

}
