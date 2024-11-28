{ pkgs
, config
, ...
}:
let
  sshCmd = "${pkgs.openssh}/bin/ssh -i ${config.age.secrets.agent-key.path} -o 'StrictHostKeyChecking=no' agent@{{ host }}";
  mkSSHSensor = host: name: cmd: minutes: {
    platform = "command_line";
    inherit name;
    scan_interval = minutes * 60;
    command = "${pkgs.openssh}/bin/ssh -i ${config.age.secrets.agent-key.path} -o 'StrictHostKeyChecking=no' ${host} ${cmd}";
  };
in
{
  services.home-assistant.config = {
    shell_command = {
      suspend_host = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl suspend"'';
      service_status = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl status {{ unit }}"'';
      service_restart = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl restart {{ unit }}"'';
      service_start = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl start {{ unit }}"'';
      service_stop = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl stop {{ unit }}"'';

      service_user_start = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ start {{ unit }}"'';
      service_user_stop = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ stop {{ unit }}"'';
      service_user_restart = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ restart {{ unit }}"'';
      service_user_status = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ status {{ unit }}"'';

      # start_steam_game = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ start steam-app@{{ gameid}}"''; #-start steam://rungameid/{{ gameid }}"'';
      # start_steam_bp = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ start steam-bigpicture"''; #-start steam://open/bigpicture"'';
    };
  };
}
