{pkgs, ...}: {
  users.extraUsers.agent = {
    isSystemUser = true;
    group = "agent";
    shell = "/run/current-system/sw/bin/bash";
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
          command = "/run/current-system/sw/bin/systemctl suspend";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl start";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl reboot";
          options = ["NOPASSWD"];
        }
        {
          command = "/run/current-system/sw/bin/systemctl status";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
