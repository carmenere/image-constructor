#!/bin/bash

continue_with_defaults () {
    echo "Do you wish to continue script with defaults ($1)?"
    select YN in "Yes" "No"; do
      case ${YN} in
        "Yes" ) break;;
        "No" ) exit;;
      esac
    done
}



prepare_apt_source_list () {
case $OS in
    "ubuntu")
        truncate -s 0 images/${OS}/${CODENAME}/etc/apt/sources.list
        cat <<EOF > images/${OS}/${CODENAME}/etc/apt/sources.list
###### Ubuntu Main Repos
deb ${APT_URI} ${CODENAME} main restricted universe multiverse
deb-src ${APT_URI} ${CODENAME} main restricted universe multiverse

###### Ubuntu Update Repos
deb ${APT_URI} ${CODENAME}-updates main restricted universe multiverse
deb-src ${APT_URI} ${CODENAME}-updates main restricted universe multiverse

deb ${APT_SECURITY_URI} ${CODENAME}-security main restricted universe multiverse
deb-src ${APT_SECURITY_URI} ${CODENAME}-security main restricted universe multiverse
EOF
        ;;
    "debian")
        truncate -s 0 images/${OS}/${CODENAME}/etc/apt/sources.list
        cat <<EOF > images/${OS}/${CODENAME}/etc/apt/sources.list
deb ${APT_URI} ${CODENAME} main contrib non-free
deb-src ${APT_URI} ${CODENAME} main contrib non-free

deb ${APT_URI} ${CODENAME}-updates main contrib non-free
deb-src ${APT_URI} ${CODENAME}-updates main contrib non-free

deb ${APT_SECURITY_URI} ${CODENAME}/updates main contrib non-free
deb-src ${APT_SECURITY_URI} ${CODENAME}/updates main contrib non-free
EOF
        ;;
esac
}

if [[ $# -eq 0 ]]
then
    echo "No arguments supplied!"
    echo "Usage: ${0##*/} OS release_codename base_image_tag [derivated_image_tag]"
    continue_with_defaults "OS=ubuntu, release_codename=xenial, tag=ubuntu/xenial:16.04"
    OS="ubuntu"
    CODENAME="xenial"
    TAG="ubuntu/xenial:16.04"
    URI="http://archive.ubuntu.com/ubuntu/"
    APT_URI="http://ru.archive.ubuntu.com/ubuntu/"
elif [[ $# -gt 4 ]] || [[ $# -lt 3 ]]
then
    echo "Incorrect arguments value supplied!"
    echo "Usage: ${0##*/} OS release_codename base_image_tag [derivated_image_tag]"
    continue_with_defaults "OS=ubuntu, release_codename=xenial, tag=ubuntu/xenial:16.04"
    OS="ubuntu"
    CODENAME="xenial"
    TAG="ubuntu/xenial:16.04"
    URI="http://archive.ubuntu.com/ubuntu/"
    APT_URI="http://ru.archive.ubuntu.com/ubuntu/"
else
  case ${1^^} in
    #Ubuntu
    "UBUNTU" )
        OS=${1,,};
        URI="http://archive.ubuntu.com/ubuntu/"
        APT_URI="http://ru.archive.ubuntu.com/ubuntu/"
        ;;
    #Debian
    "DEBIAN" )
        OS=${1,,};
        URI="http://deb.debian.org/debian/"
        APT_URI="http://deb.debian.org/debian/"
        #Debian has another URI for security updatess
        APT_SECURITY_URI="http://security.debian.org/debian-security/"
        ;;

    *)
        echo "Argument OS has incorrect vlue!"
        continue_with_defaults "OS=ubuntu"
        OS="ubuntu"
        URI="http://archive.ubuntu.com/ubuntu/"
        APT_URI="http://ru.archive.ubuntu.com/ubuntu/"
  esac

  case ${2,,} in
    #Ubuntu codenames
    "trusty"|"utopic"|"vivid"|"wily"|"xenial"|"yakkety"|"zesty"|"artful"|"bionic" )
        CODENAME=${2,,}
        ;;

    #Debian codenames
    "wheezy"|"jessie"|"stretch" )
        CODENAME=${2,,}
        ;;

    *)
        echo "Argument release_codename has incorrect vlue!"
        continue_with_defaults "release_codename=xenial"
        CODENAME="xenial"
  esac

  if [[ -n "$3" ]]; then
    TAG=$3
  else
  	TAG="ubuntu/xenial:16.04"
  fi

  if [[ -n "$4" ]]; then
    TAG2=$4
  fi

fi


if [[ -z "${APT_SECURITY_URI}" ]]; then
	APT_SECURITY_URI="${APT_URI}"
fi


echo "Script configured with following values: OS=${OS}, release_codename=${CODENAME}, tag_for_base_image=${TAG}, uri=${URI}, apt_uri=${APT_URI}, apt_security_uri=${APT_SECURITY_URI}, tag_for_derivated_image=${TAG2}, continue?"
select YN in "Yes" "No"; do
      case ${YN} in
        "Yes" ) break;;
        "No" ) exit;;
      esac
done


if [[ -e images/${OS}/${CODENAME} ]]; then
  rm -rf images/${OS}/${CODENAME}
fi

mkdir -p images/${OS}/${CODENAME}


debootstrap --help > /dev/null 2>&1
if [[ $? -ne 0 ]]
then
    echo "Command 'debootstrap' not found. May be it is not installed or installed in uncommon location."
    exit
fi


debootstrap --arch=amd64 --variant=minbase --include=bash-completion,nano,sudo,nmap,zlib1g-dev,libssl-dev,zip,unzip,git,strace,ltrace,curl,build-essential,conntrack,ipset,tcpdump,openssh-server ${CODENAME} images/${OS}/${CODENAME} ${URI}
#debootstrap --arch=amd64 --include=bash-completion,nano,sudo,nmap,zlib1g-dev,libssl-dev,zip,unzip,git,strace,ltrace,curl ${CODENAME} images/${OS}/${CODENAME} ${URI}
#debootstrap --arch=amd64 ${CODENAME} images/${OS}/${CODENAME} ${URI}

if [[ $? -ne 0 ]]
then
    echo "Command 'debootstrap' exited with error."
    exit
fi


prepare_apt_source_list


tar -C images/${OS}/${CODENAME} -c . | docker import - ${TAG}


if [[ -z "${TAG2}" ]]; then
	exit
fi

truncate -s 0 images/${OS}/${CODENAME}/Dockerfile
cat <<EOF > images/${OS}/${CODENAME}/Dockerfile
FROM ${TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt update && \
    apt upgrade -y && \
    apt clean

RUN apt install -y scapy && \
    apt install -y lshw && \
    apt install -y htop && \
    apt install -y tshark && \
    apt install -y tree && \
    apt install -y python3-dev && \
    apt install -y python3-yaml && \
    apt install -y python3-pip && \
    apt install -y python3-setuptools && \
    apt install -y python3-virtualenv && \
    apt install -y python3-numpy && \
    apt install -y python3-scipy && \
    apt install -y python3-matplotlib && \
    apt install -y python3-pandas && \
    apt install -y ipython3 && \
    pip3 install --upgrade pip setuptools && \
    apt install -y nginx && \
    apt install -y postgresql

LABEL OS="ubuntu/xenial:16.04"

ENTRYPOINT ["/bin/bash"]

EOF


docker build -f images/${OS}/${CODENAME}/Dockerfile images/${OS}/${CODENAME} --tag "${TAG2}"
