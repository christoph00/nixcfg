{
  pkgs,
  config,
  ...
}: let
  sshCmd = "${pkgs.openssh}/bin/ssh -i ${config.age.agent-key.path} agent@{{ host }}";
in {
  shell_command = {
    suspend_host = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl suspend"'';
  };
}
