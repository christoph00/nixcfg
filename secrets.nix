let
  christoph_tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJznPNQqLgyHNL2Cxbtx3RO6BncMpC1Bpyae/edKW7oH";
  christoph_x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwrR18ub6bgzehbzGzwFu4gBXPuBfkXCYLlqS9Qbal2";
  christoph_oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII1MrbLLO4xfy0qns7diUDklWd8LthvvdKIMdydKNb9f";

  # Hosts
  csrv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHkYJjXoEofN3Nb/b9Dxsc0+J2S5fUU7fZOs6hqZCvGT";
  lsrv = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGzR8Ju+yw7yBpNlwIo74Ov0bidgrqRJjL/xi64I0qzu";
  tower = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGb7cFRAsGnk/uXBceCiWwIwzev3qu/YQrZb/v166ufR";
  oca = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJjzPAtQF1ysQyoos3mDAv7vnUtlHALu7EgU4bj0McoJ";
  oc1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINQzfYiD7ugHkflIXEvCFj3o6skLLyFDlRkkoTjlyK5I";
  oc2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZwupfoft4N/wvB4DqXLcZtuFWNRbomxgf/WzhgCx2F";
  x13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICmYYt27qyW73/QHk2Q7oben7p4iLgRts//SwBzohaMx";
  one = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM7STsorCqxsu+ZQZjgsD1Zqw8ihoLKKUQgdvNS+s3F8";

  servers = [
    csrv
    lsrv
    oca
    oc1
    oc2
    one
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
in {
  #  "secrets/netbird-io-setup.key".publicKeys = all;
  #  "secrets/tailscale-key.age".publicKeys = all;
  #  "secrets/vector.env".publicKeys = all;
  "secrets/user_christoph_pw".publicKeys = all;
  "secrets/cf-api-key.age".publicKeys =
    [
      lsrv
      oca
      one
      oc1
      oc2
    ]
    ++ users;
  #  "secrets/ha-secrets.age".publicKeys = [ lsrv ] ++ users;
  #  "secrets/ha-serviceaccount.age".publicKeys = [ lsrv ] ++ users;
  #  "secrets/mqtt-agent.age".publicKeys = all;
  #  "secrets/mqtt-ha.age".publicKeys = all; # temp
  #  "secrets/sftpgo.env".publicKeys = [
  #    oca
  #    lsrv
  #    tower
  #  ] ++ users;
  #  "secrets/rclone.age".publicKeys = all;

  #  "secrets/agent-key".publicKeys = [ lsrv ] ++ users;
  #  "secrets/wyoming-openai.env".publicKeys = [
  #    lsrv
  #    oca
  #  ] ++ users;
  #  "secrets/aider.age".publicKeys = [
  #    oca
  #    x13
  #  ] ++ users;
  #  "secrets/searx.age".publicKeys = [
  #    oca
  #    oc1
  #  ] ++ users;
  #
  "secrets/wg-oca.age".publicKeys =
    [
      oca
    ]
    ++ users;
  "secrets/wg-oc1.age".publicKeys =
    [
      oc1
    ]
    ++ users;
  "secrets/wg-oc2.age".publicKeys =
    [
      oc2
    ]
    ++ users;
  "secrets/wg-lsrv.age".publicKeys =
    [
      lsrv
    ]
    ++ users;
  "secrets/wg-tower.age".publicKeys =
    [
      tower
    ]
    ++ users;
  "secrets/wg-x13.age".publicKeys =
    [
      x13
    ]
    ++ users;
  "secrets/wg-one.age".publicKeys =
    [
      one
    ]
    ++ users;
    "secrets/altmount-cfg.age".publicKeys = [
      oca
    ] ++ users;
  #  "secrets/box-key.age".publicKeys = all;
  #  "secrets/actions-runner.age".publicKeys = all;
  #  "secrets/self.age".publicKeys = all;
  #  "secrets/proxy-auth.age".publicKeys = [ oc1 ] ++ users;
  #  "secrets/pinchflat.age".publicKeys = [
  #    oca
  #    tower
  #  ] ++ users;
  #  "secrets/litellm.age".publicKeys = [ oca ] ++ users;
  #  "secrets/litellm-conf.age".publicKeys = [ oca ] ++ users;#
  #
  #  "secrets/api-keys.age".publicKeys = [
  #    oca
  #    x13
  #    tower
  #  ] ++ users;
}
