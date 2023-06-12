{
  lib,
  python3,
  fetchFromGitHub,
}:
python3.pkgs.buildPythonApplication rec {
  pname = "systemctl-mqtt";
  version = "0.5.0";
  format = "setuptools";

  src = fetchFromGitHub {
    owner = "fphammerle";
    repo = "systemctl-mqtt";
    rev = "v${version}";
    hash = "sha256-DI+bJyy/7pwrbFtylXW8m2nxPByiSLGl8vdIPPeQ1gI=";
  };

  pythonImportsCheck = ["systemctl_mqtt"];

  meta = with lib; {
    description = "MQTT client triggering & reporting shutdown on systemd-based systems :house_with_garden";
    homepage = "https://github.com/fphammerle/systemctl-mqtt";
    changelog = "https://github.com/fphammerle/systemctl-mqtt/blob/${src.rev}/CHANGELOG.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [];
  };
}
