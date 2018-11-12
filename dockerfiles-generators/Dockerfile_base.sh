#!/bin/bash

#################################################################################
#   Base image for all derivated images
#   Example: ./builder.sh ubuntu-18.04:minbase ubuntu-18.04:base Dockerfile_base
#################################################################################
Dockerfile_base () {
local DOCKERFILE_DIR=$1
local SOURCE_TAG=$2

cat <<EOF > ${DOCKERFILE_DIR}/Dockerfile_base
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt update && \
    apt upgrade -y && \
    apt clean

RUN apt install -y locales && \
    apt install -y man && \
    apt install -y less && \
    apt install -y nano && \
    apt install -y tree && \
    apt install -y sudo && \
    apt install -y zip && \
    apt install -y unzip && \
    apt install -y git && \
    apt install -y bash-completion && \
    apt install -y iputils-ping && \
    apt install -y iproute2 && \
    apt install -y dnsutils && \
    apt install -y netcat-openbsd && \
    apt install -y scapy && \
    apt install -y openssl && \
    apt install -y nmap && \
    apt install -y curl && \
    apt install -y wget && \
    apt install -y tcpdump && \
    apt clean

EOF

echo -n "${DOCKERFILE_DIR}/Dockerfile_base"
}

echo "Dockerfile_base"