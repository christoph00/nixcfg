{ lib, ... }:

{
  internal.meta = {
    "lsrv" = {
      id = 1;
      ipv4 = "192.168.2.2";
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGzR8Ju+yw7yBpNlwIo74Ov0bidgrqRJjL/xi64I0qzu";
      zone = "home";
      wireguardIP = "10.100.0.2"; # Existing IP, maybe for a central VPN?
      architecture = "x86_64";
      description = "Linux Server";
      macAddress = null; # Beispiel: "00:..."
    };
    "tower" = {
      id = 2;
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA9QsDiXxdI910DdpiwX7FnsTYASANTK7Xs/kM8hWCxN";
      zone = "home";
      wireguardIP = "10.100.0.3";
      architecture = "x86_64";
      description = "Main Desktop/Workstation";
      macAddress = null;
    };
    "oca" = {
      id = 3;
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIANvJNo6Vo6IaTx7ND2fBILxrpswvprOvFRCb+RYF1El";
      zone = "cloud";
      wireguardIP = "10.100.0.4";
      architecture = "aarch64";
      description = "Oracle Cloud Ampere VM";
      macAddress = null;
    };
    "oc1" = {
      id = 4;
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxEMuue30m1zhq/03TMgJrj1t+8hRudPPpWMM3/5o9A";
      zone = "cloud";
      wireguardIP = "10.100.0.5";
      architecture = "x86_64";
      description = "Oracle Cloud x86 VM 1";
      macAddress = null;
    };
    "oc2" = {
      id = 5;
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIND8HbngVMLrM3sfnr8tz3moOlahHFgA0BliQREX6toe";
      zone = "cloud";
      wireguardIP = "10.100.0.6";
      architecture = "x86_64";
      description = "Oracle Cloud x86 VM 2";
      macAddress = null;
    };
    "star" = { # Hinzugefügter Host
      id = 6;
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI...placeholder..."; # Bitte ersetzen
      zone = "home"; # Annahme, bitte anpassen
      wireguardIP = null; # Hat dieser Host eine zentrale WG IP?
      architecture = "x86_64"; # Annahme, bitte anpassen
      description = "Star Host (Details anpassen)";
      macAddress = null;
    };
    "x13" = { # Dieser Host ist nicht in der P2P-Liste, erhält aber eine ID
      id = 7;
      pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+dCB8RPOgkaXoRT6FnUIft5axZ0BF41wAzYPXJjRkR";
      zone = "home";
      wireguardIP = "10.100.0.7";
      architecture = "x86_64";
      description = "ThinkPad X13";
      macAddress = null;
    };
    # Füge hier weitere Hosts hinzu...
  };
}
