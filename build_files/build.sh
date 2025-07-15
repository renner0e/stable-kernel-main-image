#!/bin/bash

set -ouex pipefail

#KERNEL_PIN=
KERNEL=$(skopeo inspect --retry-times 3 docker://ghcr.io/ublue-os/akmods:coreos-stable-"$(rpm -E %fedora)" | jq -r '.Labels["ostree.linux"]')

skopeo copy --retry-times 3 docker://ghcr.io/ublue-os/akmods:coreos-stable-"$(rpm -E %fedora)" dir:/tmp/akmods
AKMODS_TARGZ=$(jq -r '.layers[].digest' </tmp/akmods/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/akmods/"$AKMODS_TARGZ" -C /tmp/
mv /tmp/rpms/* /tmp/akmods/

dnf5 -y install /tmp/kernel-rpms/kernel-{core,modules,modules-core,modules-extra}-"${KERNEL}".rpm
# CoreOS doesn't do kernel-tools, removes leftovers from newer kernel
dnf5 -y remove kernel-tools{,-libs}


# Prevent kernel stuff from upgrading again
dnf5 versionlock add kernel{,-core,-modules,-modules-core,-modules-extra,-tools,-tools-lib,-headers,-devel,-devel-matched}

