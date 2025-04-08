{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.internal.services.homeassistant;
  sshCmd = "${pkgs.openssh}/bin/ssh -i ${config.age.secrets.agent-key.path} -o 'StrictHostKeyChecking=no' agent@{{ host }}";
  mkSSHSensor = host: name: cmd: minutes: {
    platform = "command_line";
    inherit name;
    scan_interval = minutes * 60;
    command = "${pkgs.openssh}/bin/ssh -i ${config.age.secrets.agent-key.path} -o 'StrictHostKeyChecking=no' ${host} ${cmd}";
  };
in
{
  config = lib.mkIf cfg.enable {
    age.secrets.agent-key.file = ../../../../secrets/agent-key;

    services.home-assistant.config = {
      shell_command = {
        suspend_host = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl suspend"'';
        service_status = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl status {{ unit }}"'';
        service_restart = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl restart {{ unit }}"'';
        service_start = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl start {{ unit }}"'';
        service_stop = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl stop {{ unit }}"'';

        service_user_start = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ start {{ unit }}"'';
        service_user_stop = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ stop {{ unit }}"'';
        service_user_restart = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ restart {{ unit }}"'';
        service_user_status = ''${sshCmd} "doas /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ status {{ unit }}"'';

        # start_steam_game = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ start steam-app@{{ gameid}}"''; #-start steam://rungameid/{{ gameid }}"'';
        # start_steam_bp = ''${sshCmd} "sudo /run/current-system/sw/bin/systemctl --user --machine {{ user }}@ start steam-bigpicture"''; #-start steam://open/bigpicture"'';
      };
    };
  };
}
