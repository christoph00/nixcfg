{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.chr;
let
  cfg = config.chr.services.home-assistant;

  createResources = types: map (type: { inherit type; }) types;

  createResourcesWithArg = arg: types: map (type: { inherit type arg; }) types;
  createResourcesWithArgs =
    args: types: lib.flatten (map (arg: createResourcesWithArg arg types) args);
in
{
  services.home-assistant.config.sensor = mkIf cfg.enable [
    {
      platform = "systemmonitor";
      resources =
        (createResources [
          "last_boot"
          "memory_use_percent"
          "processor_use"
          "processor_temperature"
        ])
        # ++ (createResourcesWithArgs (lib.attrNames config.fileSystems) ["disk_use_percent"])
        # ++ (createResourcesWithArgs (lib.attrNames config.networking.interfaces) [
        ++ (createResourcesWithArgs [
          "/"
          "/nix"
          "/media/data-hdd"
          "/media/data-ssd"
        ] [ "disk_use_percent" ]);
      # ++ (createResourcesWithArgs ["pppoe-wan" "br-lan0"] [
      #   "ipv4_address"
      #   "throughput_network_in"
      #   "throughput_network_out"
      # ])
      # ++ (createResourcesWithArgs ["dnsmasq" "mqtt" "blocky"] ["process"]);
    }
    # {
    #   platform = "command_line";
    #   name = "OS";
    #   scan_interval = 60 * 60;
    #   command = "${pkgs.lsb-release}/bin/lsb_release --id --short";
    #   value_template = "{{ value | replace('\"', '') }}";
    # }
    # {
    #   platform = "command_line";
    #   name = "Version";
    #   scan_interval = 60 * 60;
    #   command = "${pkgs.lsb-release}/bin/lsb_release --release --short";
    #   value_template = "{{ value | replace('\"', '') }}";
    # }
    {
      platform = "command_line";
      name = "Kernel";
      scan_interval = 60 * 60;
      command = "${pkgs.coreutils}/bin/uname -r";
    }
    # {
    #   platform = "command_line";
    #   name = "Uptime";
    #   scan_interval = 60;
    #   command = "${pkgs.coreutils}/bin/uptime | ${pkgs.gawk}/bin/awk -F '( |,|:)+' '{d=h=m=0; if ($7==\"min\") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,\"days\",h+0,\"hours\",m+0,\"minutes\"}'";
    # }
  ];
}
