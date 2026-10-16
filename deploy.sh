#!/bin/bash
# deploy.sh — symlink everything listed in a MANIFEST into $HOME.
# MANIFEST row format: source|operation|destination (relative to $HOME)

set -e

SCRIPT_DIR="$( cd "$( dirname "$BASH_SOURCE[0]" )" && pwd )"

symlinkFile() {
    source="$SCRIPT_DIR/$1"
    destination="$HOME/$2"

    mkdir -p "$(dirname "$destination")"

    if [ -L "$destination" ]; then
        echo "[WARNING] $1 already symlinked"
        return
    fi

    if [ -e "$destination" ]; then
        echo "[ERROR] $destination exists but it's not a symlink. Please fix that manually"
        exit 1
    fi

    ln -s "$source" "$destination"
    echo "[OK] $1 -> $destination"
}

deployManifest() {
    while IFS= read -r row || [ -n "$row" ]; do
        case "$row" in
            \#*|"") continue ;;
        esac

        source=$(echo "$row" | cut -d \| -f 1)
        operation=$(echo "$row" | cut -d \| -f 2)
        destination=$(echo "$row" | cut -d \| -f 3)

        case "$operation" in
            symlink)
                symlinkFile "$source" "$destination"
                ;;

            *)
                echo "[WARNING] Unknown operation $operation. Skipping..."
                ;;
        esac
    done < "$SCRIPT_DIR/$1"
}

if [ -z "$1" ]; then
    echo "Usage: $0 <MANIFEST>"
    echo "ERROR: no MANIFEST file is provided"
    exit 1
fi

deployManifest "$1"
