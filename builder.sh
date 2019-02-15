#!/bin/bash

PROJECT_DIR="/home/blackswan"
GENERATORS_DIR=${PROJECT_DIR}/"image-constructor/dockerfiles-generators"
BUILD_DIR="/tmp"
DOCKERFILES_DIR="${BUILD_DIR}/docker-build"


if [[ -e ${DOCKERFILES_DIR} ]]; then
  rm -rf ${DOCKERFILES_DIR}
fi

mkdir -p ${DOCKERFILES_DIR}


. "${GENERATORS_DIR}/Dockerfile_base.sh"
. "${GENERATORS_DIR}/Dockerfile_py3dev.sh"
. "${GENERATORS_DIR}/Dockerfile_py3-for-data-science.sh"
. "${GENERATORS_DIR}/Dockerfile_nginx.sh"
. "${GENERATORS_DIR}/Dockerfile_postgresql.sh"
. "${GENERATORS_DIR}/Dockerfile_selenium.sh"
. "${GENERATORS_DIR}/Dockerfile_sshd.sh"
. "${GENERATORS_DIR}/Dockerfile_openwrt.sh"


docker_build () {
    local DOCKERFILES_DIR="$1"
    local GENERATORS_FUNC="$2"
    local SOURCE_TAG="$3"
    local TARGET_TAG="$4"
    docker build --no-cache -f $(${GENERATORS_FUNC} "${DOCKERFILES_DIR}" "${SOURCE_TAG}") "${BUILD_DIR}" --tag "${TARGET_TAG}"
}


docker_build "${DOCKERFILES_DIR}" Dockerfile_base                  ubuntu-18.04:minbase     ubuntu-18.04:base

docker_build "${DOCKERFILES_DIR}" Dockerfile_nginx                 ubuntu-18.04:base        ubuntu-18.04:nginx
docker_build "${DOCKERFILES_DIR}" Dockerfile_postgresql            ubuntu-18.04:base        ubuntu-18.04:postgresql

docker_build "${DOCKERFILES_DIR}" Dockerfile_py3dev                ubuntu-18.04:postgresql  ubuntu-18.04:py3dev
docker_build "${DOCKERFILES_DIR}" Dockerfile_py3-for-data-science  ubuntu-18.04:py3dev      ubuntu-18.04:py3-for-data-science

docker_build "${DOCKERFILES_DIR}" Dockerfile_selenium              ubuntu-18.04:py3-for-data-science  ubuntu-18.04:scraper-dev
docker_build "${DOCKERFILES_DIR}" Dockerfile_openwrt               ubuntu-18.04:py3-for-data-science  ubuntu-18.04:openwrt

docker_build "${DOCKERFILES_DIR}" Dockerfile_sshd                  ubuntu-18.04:nginx        nginx:v0.1
docker_build "${DOCKERFILES_DIR}" Dockerfile_sshd                  ubuntu-18.04:postgresql   postgresql:v0.1
docker_build "${DOCKERFILES_DIR}" Dockerfile_sshd                  ubuntu-18.04:scraper-dev  polygon:v0.1
docker_build "${DOCKERFILES_DIR}" Dockerfile_sshd                  ubuntu-18.04:openwrt      openwrt:v0.1


#docker network create --subnet=172.18.0.0/24 lab
#docker run --restart=unless-stopped --privileged --net=lab --ip=172.18.0.2 --hostname=polygon    --name=polygon      -d  polygon:v0.1
#docker run --restart=unless-stopped --privileged --net=lab --ip=172.18.0.5 --hostname=openwrt    --name=openwrt      -d  openwrt:v0.1

#docker run --restart=unless-stopped --net=lab --ip=172.18.0.3 --hostname=postgresql --name=postgresql   -d  postgresql:v0.1
#docker run --restart=unless-stopped --net=lab --ip=172.18.0.4 --hostname=nginx      --name=nginx        -d  nginx:v0.1


#mkdir -p /var/docker/volumes
#mkdir /var/docker/volumes/PostgreSQL
#mkdir /var/docker/volumes/Front
#mkdir /var/docker/volumes/Back
#mkdir /var/docker/volumes/GAS
#mkdir /var/docker/volumes/Jupyter

#docker run --restart=unless-stopped --net=lab --ip=172.18.0.2 --hostname=polygon                                            --name=Polygon    -d  polygon
#docker run --restart=unless-stopped --net=lab --ip=172.18.0.3 --hostname=postgres -v /var/docker/volumes/PostgreSQL:/HostFS --name=PostgreSQL -d  postgres:v0.1
#docker run --restart=unless-stopped --net=lab --ip=172.18.0.4 --hostname=jupyter  -v /var/docker/volumes/Jupyter:/HostFS    --name=Jupyter    -d  jupyter:v0.1
#docker run --restart=unless-stopped --net=lab --ip=172.18.0.5 --hostname=backend  -v /var/docker/volumes/Back:/HostFS       --name=Back       -d  backend:v0.1
#docker run --restart=unless-stopped --net=lab --ip=172.18.0.6 --hostname=scraper  -v /var/docker/volumes/GAS:/HostFS        --name=Scraper    -d  scraper:v0.1
#docker run --restart=unless-stopped --net=lab --ip=172.18.0.7 --hostname=frontend -v /var/docker/volumes/Front:/HostFS      --name=Front      -d  frontend:v0.1
