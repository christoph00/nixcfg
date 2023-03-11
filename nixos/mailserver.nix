{
  config,
  pkgs,
  lib,
  ...
}: let
  certDir = config.security.acme.certs."mx.r505.de".directory;
in {
  environment.systemPackages = [pkgs.vmt pkgs.vomit-sync pkgs.openssl pkgs.maddy];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "christoph@asche.co";
    };
    certs."mx.r505.de" = {
      domain = "mx.r505.de";
      dnsProvider = "cloudflare";
      credentialsFile = config.age.secrets.cf-acme.path;
      dnsResolver = "1.1.1.1:53";
      postRun = ''
        sed -i 's/EC\ PRIVATE/PRIVATE/g' key.pem
      '';
    };
  };

  users.users.maddy.extraGroups = ["acme"];
  services.maddy = {
    enable = true;
    openFirewall = true;
    hostname = "mx.r505.de";
    primaryDomain = "mx.r505.de";
    localDomains = ["asche.co" "r505.de"];
    config = ''

      tls file ${certDir}/fullchain.pem ${certDir}/key.pem

      # ----------------------------------------------------------------------------
      # Local storage & authentication

      # pass_table provides local hashed passwords storage for authentication of
      # users. It can be configured to use any "table" module, in default
      # configuration a table in SQLite DB is used.
      # Table can be replaced to use e.g. a file for passwords. Or pass_table module
      # can be replaced altogether to use some external source of credentials (e.g.
      # PAM, /etc/shadow file).
      #
      # If table module supports it (sql_table does) - credentials can be managed
      # using 'maddy creds' command.

      auth.pass_table local_authdb {
          table sql_table {
              driver sqlite3
              dsn credentials.db
              table_name passwords
          }
      }

      # imapsql module stores all indexes and metadata necessary for IMAP using a
      # relational database. It is used by IMAP endpoint for mailbox access and
      # also by SMTP & Submission endpoints for delivery of local messages.
      #
      # IMAP accounts, mailboxes and all message metadata can be inspected using
      # imap-* subcommands of maddy.

      storage.imapsql local_mailboxes {
          driver sqlite3
          dsn imapsql.db
      }

      # ----------------------------------------------------------------------------
      # SMTP endpoints + message routing

      table.chain local_rewrites {
          optional_step regexp "(.+)\+(.+)@(.+)" "$1@$3"
          optional_step static {
              entry postmaster postmaster@$(primary_domain)
          }
         # optional_step file /etc/maddy/aliases
      }

      msgpipeline local_routing {
          # Insert handling for special-purpose local domains here.
          # e.g.
          # destination lists.example.org {
          #     deliver_to lmtp tcp://127.0.0.1:8024
          # }

          destination postmaster $(local_domains) {
              modify {
                  replace_rcpt &local_rewrites
              }

              deliver_to &local_mailboxes
          }

          default_destination {
              reject 550 5.1.1 "User doesn't exist"
          }
      }

      smtp tcp://0.0.0.0:25 {
          limits {
              # Up to 20 msgs/sec across max. 10 SMTP connections.
              all rate 20 1s
              all concurrency 10
          }

          dmarc yes
          check {
              require_mx_record
              dkim
              spf
          }

          source $(local_domains) {
              reject 501 5.1.8 "Use Submission for outgoing SMTP"
          }
          default_source {
              destination postmaster $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  reject 550 5.1.1 "User doesn't exist"
              }
          }
      }

      submission tls://0.0.0.0:465 tcp://0.0.0.0:587 {
          limits {
              # Up to 50 msgs/sec across any amount of SMTP connections.
              all rate 50 1s
          }

          auth &local_authdb

          source $(local_domains) {
              check {
                  authorize_sender {
                      prepare_email &local_rewrites
                      user_to_email identity
                  }
              }

              destination postmaster $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  modify {
                      dkim $(primary_domain) $(local_domains) default
                  }
                  deliver_to &remote_queue
              }
          }
          default_source {
              reject 501 5.1.8 "Non-local sender domain"
          }
      }

      target.remote outbound_delivery {
          limits {
              # Up to 20 msgs/sec across max. 10 SMTP connections
              # for each recipient domain.
              destination rate 20 1s
              destination concurrency 10
          }
          mx_auth {
              dane
              mtasts {
                  cache fs
                  fs_dir mtasts_cache/
              }
              local_policy {
                  min_tls_level encrypted
                  min_mx_level none
              }
          }
      }

      target.queue remote_queue {
          target &outbound_delivery

          autogenerated_msg_domain $(primary_domain)
          bounce {
              destination postmaster $(local_domains) {
                  deliver_to &local_routing
              }
              default_destination {
                  reject 550 5.0.0 "Refusing to send DSNs to non-local addresses"
              }
          }
      }

      # ----------------------------------------------------------------------------
      # IMAP endpoints

      imap tls://0.0.0.0:993 tcp://0.0.0.0:143 {
          auth &local_authdb
          storage &local_mailboxes
      }

    '';
  };
}
