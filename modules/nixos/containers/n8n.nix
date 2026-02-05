{
  lib,
  config,
  flake,
  ...
}: let
  inherit (lib) mkIf mkDefault mkForce;
  inherit (flake.lib) btrfsVolume mountVolume mkBoolOpt mkSecret;
in {
  options.cnt.n8n = {
    enable = mkBoolOpt false;
  };
  config = mkIf config.cnt.n8n.enable {
    age.secrets."n8n-env" = mkSecret {
      file = "n8n-env";
    };

    virtualisation.quadlet = let
      inherit (config.virtualisation.quadlet) pods volumes;
      btrfsvol = btrfsVolume config.disko;
    in {
      pods.n8n.podConfig = {
        publishPorts = ["127.0.0.1:5678:5678"];
      };
      volumes = {
        n8n = btrfsvol {
          subvol = "@volumes/n8n";
        };
      };
      containers.n8n-main = {
        containerConfig = {
          image = "docker.n8n.io/n8nio/n8n:beta";
          pod = pods.n8n.ref;
          mounts = [
            (mountVolume {
              volume = volumes.n8n.ref;
              subpath = "/home";
              destination = "/home/node/.n8n";
            })
          ];
          user = "1000";
          group = "100";
          environments = {
            DB_TYPE = "sqlite";
            N8N_HOST = "n8n.r505.de";
            N8N_PORT = "5678";
            N8N_PROTOCOL = "https";
            WEBHOOK_URL = "https://n8n.r505.de/";
            N8N_RUNNERS_ENABLED = "true";
            N8N_RUNNERS_MODE = "external";
            N8N_RUNNERS_JAVASCRIPT_ENABLED = "true";
            N8N_RUNNERS_PYTHON_ENABLED = "true";
            N8N_RUNNERS_BROKER_PORT = "5101";
            NODE_ENV = "production";
            N8N_SECURE_COOKIE = "true";
            N8N_PROXY_SSL_HEADER = "X-Forwarded-Proto";
          };
          environmentFiles = [config.age.secrets."n8n-env".path];
          labels = {
            "io.containers.autoupdate" = "registry";
          };
        };
      };
      containers.n8n-runner.containerConfig = {
        image = "docker.io/n8nio/runners:beta";
        pod = pods.n8n.ref;
        user = "1000";
        group = "100";
        environments = {
          N8N_RUNNERS_TASK_BROKER_URI = "http://localhost:5101";
        };
        environmentFiles = [config.age.secrets."n8n-env".path];
        labels = {
          "io.containers.autoupdate" = "registry";
        };
      };
    };
  };
}
