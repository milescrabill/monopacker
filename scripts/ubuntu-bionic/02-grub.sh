#!/bin/bash

set -exv

# init helpers
helpers_dir=${MONOPACKER_HELPERS_DIR:-"/etc/monopacker/scripts"}
. ${helpers_dir}/*.sh

# GRUB
# adapted from https://bgstack15.wordpress.com/2018/05/02/update-etc-default-grub-programmatically/
GRUB_INFILE=/etc/default/grub

cp -p "${GRUB_INFILE}" "${GRUB_INFILE}.orig"

TMP_DIR="$(mktemp -d)"
TMP_FILE="$(TMPDIR="${TMP_DIR}" mktemp)"

# clean up temp file if necessary
test ! -e "${TMP_FILE}" && { touch "${TMP_FILE}" || exit 1 ; }
cat "${GRUB_INFILE}" > "${TMP_FILE}"

add_value_to_grub_line "${TMP_FILE}" "GRUB_CMDLINE_LINUX" "debug g"
add_value_to_grub_line "${TMP_FILE}" "GRUB_CMDLINE_LINUX_DEFAULT" "splash"
remove_value_from_grub_line "${TMP_FILE}" "GRUB_CMDLINE_LINUX_DEFAULT" "quiet"

update_grub_if_changed "${GRUB_INFILE}" "${TMP_FILE}"

# show final results
cat "${GRUB_INFILE}"
rm -rf "${TMP_DIR}" 2>/dev/null

# FIXME does not exist?
# shown here https://launchpad.net/ubuntu/+source/linux-signed/4.15.0-58.64
# retry apt install -y linux-image-$KERNEL_VERSION-dbgsym

shutdown -r now

# Continues in next script
