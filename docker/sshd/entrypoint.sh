#!/bin/sh
ssh-keygen -A

SSHD_DATA_PATH="/data"

create_keys() {
  local key_name="$1"
  local ssh_path="$2"

  local filename="${SSHD_DATA_PATH}/${key_name}"
  local authorized_keys="${ssh_path}/authorized_keys"

  if [ ! -f ${filename} ]; then
    mkdir -p "${SSHD_DATA_PATH}" "${ssh_path}"
    ssh-keygen -t ed25519 -f "${filename}" -q -N ""
    touch "${authorized_keys}"
    cat ${filename}.pub >> "${authorized_keys}"
    echo "*** SSHD key created: ${filename}"
  fi
}

if [ ${SSHD_CREATE_ROOT_KEY} ]; then
  create_keys "root" "/root/.ssh"
fi

echo "*** BASTION_USER: ${BASTION_USER}"
if [ -n "${BASTION_USER}" ] && ! id -u "${BASTION_USER}" ; then
    HOME_PATH="/home/${BASTION_USER}"
    adduser -h "${HOME_PATH}" -s /bin/sh -D "${BASTION_USER}"
    echo -n "${BASTION_USER}:${BASTION_PASSWORD}" | chpasswd
    mkdir -p "${HOME_PATH}/.ssh" && chown "${BASTION_USER}" "${HOME_PATH}/.ssh"
    echo "*** user added: ${BASTION_USER}"
    if ${SSHD_CREATE_BASTION_KEY}; then
      create_keys "${BASTION_USER}" "${HOME_PATH}"
    fi
fi

exec /usr/sbin/sshd -D -e "$@"