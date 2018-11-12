#!/bin/bash

################################################################################
#   Nginx
#   Example: ./builder.sh ubuntu-18.04:base ubuntu-18.04:nginx Dockerfile_nginx
################################################################################
Dockerfile_nginx () {
local DOCKERFILE_DIR=$1
local SOURCE_TAG=$2

cat <<EOF > ${DOCKERFILE_DIR}/Dockerfile_nginx
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt install -y nginx && \
    apt clean

EOF

echo -n "${DOCKERFILE_DIR}/Dockerfile_nginx"

}

echo Dockerfile_nginx