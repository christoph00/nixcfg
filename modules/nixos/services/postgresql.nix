{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib) mkIf;

in
{

  config = mkIf config.services.postgresql.enable {

    sys.state.directories = [ "/var/lib/audiobookshelf" ];
    services.postgresql = {
      enableTCPIP = true;

      package = pkgs.postgresql_17.withPackages (p: [ p.pgvector ]);

      settings = {
        port = 5432;
        max_connections = 200;
        listen_addresses = lib.mkForce "*";
        password_encryption = "scram-sha-256";
      };
       authentication = lib.mkOverride 10 ''
        # TYPE  DATABASE  USER  ADDRESS         METHOD  OPTIONS

        # Unix socket connections - require password for non-postgres users
        local   all       postgres                peer

        # Localhost connections - require password
        host    all       postgres   127.0.0.1/32    scram-sha-256
        host    all       all        127.0.0.1/32    scram-sha-256
        host    all       all        ::1/128         scram-sha-256

        # Podman network - require password (containers should use passwords)
        host    all       all        10.88.0.0/16    scram-sha-256

        # Local networks - password (TODO: SSL)
        # host all       postgres   192.168.0.0/16  scram-sha-256
        # host all       all        192.168.0.0/16  scram-sha-256

        # Reject all other connections
        host    all       all        0.0.0.0/0       reject
        host    all       all        ::/0            reject
      '';
    };

  };

}
