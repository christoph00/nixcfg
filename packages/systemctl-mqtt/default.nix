{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "systemctl-mqtt";
  version = "unstable-2024-11-29";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "fphammerle";
    repo = "systemctl-mqtt";
    rev = "5e8bd7ac82b5d217ac31563699519f5da597220f";
    hash = "sha256-dWuikKT8dEC915SkcgVDj2nMafl/zZX+1ywRDBSAD1w=";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  pythonImportsCheck = [
    "systemctl_mqtt"
  ];

  meta = {
    description = "MQTT client triggering & reporting shutdown on systemd-based systems :house_with_garden";
    homepage = "https://github.com/fphammerle/systemctl-mqtt";
    changelog = "https://github.com/fphammerle/systemctl-mqtt/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "systemctl-mqtt";
  };
}
