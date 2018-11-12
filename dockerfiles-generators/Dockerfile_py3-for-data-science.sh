#!/bin/bash

################################################################################################################
#   Py3-for-data-science
#   Example: ./builder.sh ubuntu-18.04:py3dev ubuntu-18.04:py3-for-data-science Dockerfile_py3-for-data-science
################################################################################################################
Dockerfile_py3-for-data-science () {
local DOCKERFILE_DIR=$1
local SOURCE_TAG=$2

cat <<EOF > ${DOCKERFILE_DIR}/Dockerfile_py3-for-data-science
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt install -y python3-yaml && \
    apt install -y python3-numpy && \
    apt install -y python3-scipy && \
    apt install -y python3-pandas && \
    apt install -y libatlas-base-dev libatlas3-base && \
    apt install -y python3-matplotlib && \
    apt clean && \
    python3 -m pip install seaborn && \
    python3 -m pip install -U scikit-learn

RUN apt install -y ipython3 && \
    apt clean && \
    python3 -m pip install jupyter

EOF

echo -n "${DOCKERFILE_DIR}/Dockerfile_py3-for-data-science"

}

echo Dockerfile_py3-for-data-science