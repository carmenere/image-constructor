#!/bin/bash

##################################################################################################
#   openwrt
#   Example: ./builder.sh ubuntu-18.04:base ubuntu-18.04:openwrt Dockerfile_openwrt
##################################################################################################

Dockerfile_openwrt () {
local DOCKERFILE_DIR=$1
local SOURCE_TAG=$2

cat <<EOF > ${DOCKERFILE_DIR}/Dockerfile_openwrt
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt install -y m4 subversion libncurses5-dev zlib1g-dev gawk git ccache gettext xsltproc wget unzip python qemu-system-x86 curl uuid-dev libsqlite3-dev clang libpcre3-dev libbz2-dev libev-dev libssl-dev && \
    apt install -y npm && \
    apt clean

RUN sh <(curl -sL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)

EOF

echo -n "${DOCKERFILE_DIR}/Dockerfile_openwrt"
}

echo Dockerfile_openwrt
