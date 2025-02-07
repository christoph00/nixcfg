{
# Snowfall Lib provides a customized `lib` instance with access to your flake's library
# as well as the libraries available from your flake's inputs.
lib,
# An instance of `pkgs` with your overlays and packages applied is also available.
pkgs,
# You also have access to your flake's inputs.
inputs,
# Additional metadata is provided by Snowfall Lib.
namespace,
# The namespace used for your flake, defaulting to "internal" if not set.
system,
# The system architecture for this host (eg. `x86_64-linux`).
target,
# The Snowfall Lib target for this system (eg. `x86_64-iso`).
format,
# A normalized name for the system target (eg. `iso`).
virtual,
# A boolean to determine whether this system is a virtual target using nixos-generators.
systems, # An attribute map of your defined hosts.

# All other arguments come from the module system.
config, ... }:

with builtins;
with lib;
with lib.internal;

let cfg = config.internal.services.monitoring;

in {

  options.internal.services.monitoring = {
    enable = mkBoolOpt false "Enable Monitoring Service.";
    hostMetrics = mkBoolOpt false "Enable Host Metrics";
    logFiles = lib.mkOption {
      default = [ ];
      type = lib.types.listOf lib.types.path;
    };
  };

  config = mkIf cfg.enable {

    services.vector = let
      systemctlShow = [
        "${config.systemd.package}/bin/systemctl"
        "show"
        "--no-pager"
        "--timestamp=unix"
      ];

      commonProps = [
        "Id"
        "ActiveState"
        "SubState"
        "Result"
        "Slice"
        "StateChangeTimestamp"
      ];

      commonPropsArg = builtins.concatStringsSep "," commonProps;

      servicePropsArg = builtins.concatStringsSep "," (commonProps ++ [
        "CleanResult"
        "ControlPID"
        "CPUUsageNSec"
        "CPUQuotaPerSecUSec"
        "ExecMainPID"
        "IOReadBytes"
        "IOReadOperations"
        "IOWriteBytes"
        "IOWriteOperations"
        "IPEgressBytes"
        "IPEgressPackets"
        "IPIngressBytes"
        "IPIngressPackets"
        "MemoryAvailable"
        "MemoryCurrent"
        "MemoryLow"
        "MemoryMax"
        "MemoryMin"
        "MemoryPeak"
        "MemorySwapCurrent"
        "MemorySwapMax"
        "MemorySwapPeak"
        "MemoryZSwapCurrent"
        "MemoryZSwapMax"
        "ReloadResult"
        "TasksCurrent"
        "TasksMax"
      ]);

      timerPropsArg = builtins.concatStringsSep ","
        (commonProps ++ [ "NextElapseUSecRealtime" "LastTriggerUSec" ]);
      execOpts = {
        type = "exec";
        mode = "scheduled";
        framing.method = "bytes";
        include_stderr = false;
        decoding.codec = "vrl";
        decoding.vrl.source = builtins.readFile ./systemd.vrl;
      };
    in {
      enable = true;
      journaldAccess = true;
      settings = {
        api.enabled = true;

        sources = {
          # Keys here are just unique identifiers
          journald_local = {
            type = "journald";
            current_boot_only = true;
          };
          logs_local = lib.mkIf (cfg.logFiles != [ ]) {
            type = "file";
            include = cfg.logFiles;
            exclude = [
              "/var/log/btmp"
              "/var/log/btmp.1"
              "/var/log/journal/**/*"
              "/var/log/journal/*"
              "/var/log/lastlog"
              "/var/log/messages"
              "/var/log/private"
              "/var/log/warn"
              "/var/log/wtmp"
            ];
          };
          systemd_local_common = execOpts // {
            scheduled.exec_interval_secs = 60;
            command = systemctlShow
              ++ [ "--type=mount,socket,target" "-p" commonPropsArg ];
          };
          systemd_local_timers = execOpts // {
            scheduled.exec_interval_secs = 60;
            command = systemctlShow ++ [ "--type=timer" "-p" timerPropsArg ];
          };
          systemd_local_services = execOpts // {
            scheduled.exec_interval_secs = 5;
            command = systemctlShow
              ++ [ "--type=scope,service,slice" "-p" servicePropsArg ];
          };
          host_local = lib.mkIf (cfg.hostMetrics) {
            type = "host_metrics";
            collectors = [ "cpu" "load" "memory" "network" ];
          };
        };
        transforms = {
          journald_sanitize = {
            type = "remap";
            inputs = [ "journald_local" ];
            # TODO parse firewall logs
            source = builtins.readFile ./journald.vrl;
          };
          systemd_convert = {
            type = "log_to_metric";
            inputs = [
              "systemd_local_common"
              "systemd_local_timers"
              "systemd_local_services"
            ];
            all_metrics = true;
            metrics = [ ];
          };
        };

        sinks.axiom = {
          type = "axiom";
          inputs = [
            #"systemd_convert"
            "journald_sanitize"
          ];
          token = "\${AXIOM_TOKEN:-fix}";
          dataset = "\${AXIOM_DATASET:-fix}";
        };
      };
    };
    systemd.services.vector.serviceConfig.EnvironmentFile =
      config.age.secrets.vector.path;

  };
}
