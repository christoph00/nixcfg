{pkgs, ...}: {
  users.extraUsers.agent = {
    isSystemUser = true;
    group = "agent";
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDSURQwh5eAA3KiOAw9LmlJ+wuKXeboy7IjXktRNu+7X"
    ];
  };

  users.groups.agent = {};

  security.sudo.extraRules = [
    {
      users = ["agent"];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
