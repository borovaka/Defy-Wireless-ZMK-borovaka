#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Builds the firmware in ZMK's container, as the GitHub workflow does:
#
#   ./build.sh                  the halves, with the radio firmware they
#                               install, and the Neuron
#   ./build.sh neuron-hybrid    only the Neuron, which holds the keymap
#
# The images land in firmware/. The first run fetches ZMK, Zephyr and the
# zmk-defy-wireless module into this folder, about 3 GB. Build trees and
# ccache's cache stay in the defy-wireless-zmk-build Docker volume between runs,
# so a rebuild compiles only what changed.
#
# The image is the one the module's scripts/zmk pins at the tag in
# config/west.yml; update it here together with that tag.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
image="${ZMK_IMAGE:-zmkfirmware/zmk-dev-arm@sha256:77b62cbc6c62ca0026ed9eb511dd7fc2a13692d1b9ddbaf92bca510612390db8}"
if [ $# -eq 0 ]; then
    set -- left-hybrid-radio right-hybrid-radio neuron-hybrid
fi

# ccache refuses a compile whose -specs file it cannot find from the build
# directory, as the ARM builds' -specs=picolibc.specs; the SDK is part of the
# pinned image, so ccache can leave that option out of its hash.
args=(--rm -v "$PWD:/repo" -w /repo -v defy-wireless-zmk-build:/build
      -e CCACHE_DIR=/build/ccache -e "CCACHE_IGNOREOPTIONS=-specs=*")
if [ -t 0 ] && [ -t 1 ]; then
    args+=(-it)
fi
# SELinux, as on Fedora, keeps containers out of the mounted folder.
if command -v selinuxenabled > /dev/null && selinuxenabled; then
    args+=(--security-opt label=disable)
fi

docker run "${args[@]}" "$image" bash -c '
    set -e
    [ -d .west ] || west init -l config
    west update --narrow --fetch-opt=--depth=1
    # ZMK looks for Zephyr beside its app/; here Zephyr sits beside ZMK.
    west zephyr-export > /dev/null
    module="$(west list -f "{abspath}" zmk-defy-wireless)"
    python3 "$module/scripts/build" --container --zmk zmk --config config --output firmware "$@"
' build "$@"
