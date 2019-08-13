#!/bin/bash

set -exv

# init helpers
helpers_dir=${MONOPACKER_HELPERS_DIR:-"/etc/monopacker/scripts"}
. ${helpers_dir}/*.sh

echo "start kernel: $(uname -r)"

# prevents interactive installation
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
export DEBIAN_FRONTEND=noninteractive

# Update kernel
# We install the generic kernel because it has the V4L2 driver
KERNEL_VERSION=4.15.0-58-generic

retry apt update

# Upgrade to the latest kernel from the base image. If not, a bug in apt-get remove
# may install a newer kernel after we remove the old one
retry apt install -y unattended-upgrades
unattended-upgrade

# uninstall old kernel
apt remove -yq $(ls -1 /boot/vmlinuz-*{aws,gcp} | sed -e 's,/boot/vmlinuz,linux-image,')
apt autoremove -y --purge

# install new kernel
# install crash debug tools
retry apt install -y \
    linux-image-$KERNEL_VERSION \
    linux-modules-$KERNEL_VERSION \
    linux-modules-extra-$KERNEL_VERSION \
    linux-headers-$KERNEL_VERSION \
    linux-crashdump

# kernel debug
grep 'USE_KDUMP' /etc/default/kdump-tools
echo 'USE_KDUMP=1' >> /etc/default/kdump-tools
kdump-config show

# FIXME does not exist?
# shown here https://launchpad.net/ubuntu/+source/linux-signed/4.15.0-58.64
# retry apt install -y linux-image-$KERNEL_VERSION-dbgsym

shutdown -r now

# Continues in next script