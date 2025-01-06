remote-user := `whoami`
local-hostname := `hostname`

is-local-host hostname:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{hostname}}" = "{{local-hostname}}" ] || \
       [ "{{hostname}}" = "localhost" ] || \
       [ "{{hostname}}" = "127.0.0.1" ]; then
        exit 0
    else
        exit 1
    fi

build hostname:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Erstelle System-Konfiguration für {{hostname}}..."
    nix build .#nixosConfigurations."{{hostname}}".config.system.build.toplevel --impure
    echo "Closure erstellt unter: $(readlink -f result)"

copy hostname:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! just is-local-host {{hostname}} 2>/dev/null; then
        CLOSURE_PATH="$(readlink -f result)"
        echo "Kopiere Closure nach {{hostname}}..."
        nix-copy-closure --to "{{remote-user}}@{{hostname}}" "$CLOSURE_PATH"
    else
        echo "Überspringe Kopieren für lokalen Host"
    fi

activate hostname mode:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ ! "{{mode}}" =~ ^(boot|switch)$ ]]; then
        echo "Aktivierungsmodus muss 'boot' oder 'switch' sein"
        exit 1
    fi
    CLOSURE_PATH="$(readlink -f result)"
    echo "Aktiviere Konfiguration auf {{hostname}} mit Modus: {{mode}}..."
    if just is-local-host {{hostname}} 2>/dev/null; then
        doas nix-env -p /nix/var/nix/profiles/system --set "$CLOSURE_PATH" && \
        doas "$CLOSURE_PATH/bin/switch-to-configuration" {{mode}}
    else
        ssh "{{remote-user}}@{{hostname}}" "doas nix-env -p /nix/var/nix/profiles/system --set $CLOSURE_PATH && doas $CLOSURE_PATH/bin/switch-to-configuration {{mode}}"
    fi
    if [ "{{mode}}" = "boot" ]; then
        echo "Konfiguration wird beim nächsten Boot aktiviert"
        if ! just is-local-host {{hostname}} 2>/dev/null; then
            echo "System kann neu gestartet werden mit: ssh {{remote-user}}@{{hostname}} 'doas reboot'"
        else
            echo "System kann neu gestartet werden mit: doas reboot"
        fi
    else
        echo "Konfiguration erfolgreich aktiviert!"
    fi

prepare hostname: (build hostname) (copy hostname)

deploy hostname *args="": (build hostname) (copy hostname)
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -n "{{args}}" ]; then
        just activate {{hostname}} {{args}}
    else
        echo "Konfiguration wurde gebaut und kopiert, aber nicht aktiviert"
        echo "Zum Aktivieren: just activate {{hostname}} <boot|switch>"
    fi

deploy-all hostname mode: (deploy hostname mode)

help:
    @echo "Verfügbare Befehle:"
    @echo "  just build <hostname>              - Baut die Konfiguration"
    @echo "  just copy <hostname>               - Kopiert die gebaute Konfiguration zum Host"
    @echo "  just activate <hostname> <mode>    - Aktiviert die Konfiguration (mode: boot|switch)"
    @echo "  just prepare <hostname>            - Baut und kopiert die Konfiguration"
    @echo "  just deploy <hostname> [mode]      - Baut, kopiert und aktiviert optional die Konfiguration"
    @echo "  just deploy-all <hostname> <mode>  - Führt alle Schritte nacheinander aus"
