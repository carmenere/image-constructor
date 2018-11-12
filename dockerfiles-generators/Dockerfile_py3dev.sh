#!/bin/bash

##################################################################################################
#   py3dev
#   Example: ./builder.sh ubuntu-18.04:base ubuntu-18.04:py3dev Dockerfile_py3dev
##################################################################################################
Dockerfile_py3dev () {
local DOCKERFILE_DIR=$1
local SOURCE_TAG=$2

cat <<EOF > ${DOCKERFILE_DIR}/Dockerfile_py3dev
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt install -y build-essential && \
    apt install -y python3-dev && \
    apt install -y python3-pip && \
    apt install -y python3-setuptools && \
    python3 -m pip install --upgrade pip setuptools && \
    apt clean

EOF

echo -n "${DOCKERFILE_DIR}/Dockerfile_py3dev"
}

echo Dockerfile_py3dev