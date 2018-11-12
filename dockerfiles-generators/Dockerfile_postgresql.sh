#!/bin/bash

##########################################################################################
#   PostgreSQL
#   Example: ./builder.sh ubuntu-18.04:base ubuntu-18.04:postgresql Dockerfile_postgresql
##########################################################################################
Dockerfile_postgresql () {
local DOCKERFILE_DIR=$1
local SOURCE_TAG=$2

cat <<EOF > ${DOCKERFILE_DIR}/Dockerfile_postgresql
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt install -y postgresql && \
    apt clean

EOF

echo -n "${DOCKERFILE_DIR}/Dockerfile_postgresql"

}

echo Dockerfile_postgresql