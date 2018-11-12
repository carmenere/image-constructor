#!/bin/bash

###########################################################################################
#   Docker with sshd
#   Example: ./builder.sh ubuntu-18.04:nginx                frontend:v0.1  Dockerfile_sshd
#   Example: ./builder.sh ubuntu-18.04:postgresql           database:v0.1  Dockerfile_sshd
#   Example: ./builder.sh ubuntu-18.04:py3-for-data-science polygon:v0.1   Dockerfile_sshd
###########################################################################################
Dockerfile_sshd () {
################
# DECLARE VARS #
################
local LOCALE='/etc/default/locale'
local PASSWD="1"
local USER="blackswan"
local SECRET="$(echo $(openssl passwd -1 ${PASSWD}) | sed 's/\$/\\$/g')"

local DOCKERFILE_DIR=$1
local SOURCE_TAG=$2

cat <<EOF > ${DOCKERFILE_DIR}/Dockerfile_sshd
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt install -y openssh-server && \
    apt clean

RUN service ssh start

RUN sed -i '/PermitRootLogin/cPermitRootLogin no' /etc/ssh/sshd_config

RUN useradd -p "${SECRET}" -s /bin/bash -m ${USER} && \
    usermod -a -G sudo ${USER}

RUN locale-gen ru_RU.UTF-8 && \
    locale-gen en_US.UTF-8 && \
    update-locale && \
    echo 'LANG="en_US.UTF-8"' > ${LOCALE} && \
    echo 'LC_TIME="ru_RU.UTF-8"' >> ${LOCALE}

RUN sed -i '\/etc\/bash_completion/s/^#//'  /root/.bashrc && \
    sed -i '/\. \/etc\/bash_completion/afi' /root/.bashrc

ENTRYPOINT ["/usr/sbin/sshd", "-D"]
EOF

echo -n "${DOCKERFILE_DIR}/Dockerfile_sshd"

}

echo Dockerfile_sshd