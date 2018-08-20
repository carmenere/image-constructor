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
        truncate -s 0 /tmp/${OS}/${CODENAME}/etc/apt/sources.list
        cat <<EOF > /tmp/${OS}/${CODENAME}/etc/apt/sources.list
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
        truncate -s 0 /tmp/${OS}/${CODENAME}/etc/apt/sources.list
        cat <<EOF > /tmp/${OS}/${CODENAME}/etc/apt/sources.list
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
    echo "ERROR: No arguments supplied!"
    echo ""
    echo "Usage: ${0##*/} OS release_codename base_image_tag"
    continue_with_defaults "OS=ubuntu, release_codename=xenial, tag=ubuntu/xenial:16.04"
    OS="ubuntu"
    CODENAME="xenial"
    TAG="ubuntu/xenial:16.04"
    URI="http://archive.ubuntu.com/ubuntu/"
    APT_URI="http://ru.archive.ubuntu.com/ubuntu/"
elif [[ $# -ne 3 ]]
then
    echo "ERROR: Incorrect arguments value supplied!"
    echo ""
    echo "Usage: ${0##*/} OS release_codename base_image_tag"
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
        echo ""
        echo "ERROR: Argument OS has incorrect value!"
        echo ""
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


if [[ -e /tmp/${OS}/${CODENAME} ]]; then
  rm -rf /tmp/${OS}/${CODENAME}
fi

mkdir -p /tmp/${OS}/${CODENAME}


debootstrap --help > /dev/null 2>&1
if [[ $? -ne 0 ]]
then
    echo "Command 'debootstrap' not found. May be it is not installed or installed in uncommon location."
    exit
fi


debootstrap --arch=amd64 --variant=minbase ${CODENAME} /tmp/${OS}/${CODENAME} ${URI}
#debootstrap --arch=amd64 --variant=minbase --include=bash-completion,nano,sudo,nmap,zlib1g-dev,libssl-dev,zip,unzip,git,strace,ltrace,curl,build-essential,conntrack,ipset,tcpdump,openssh-server ${CODENAME} /tmp/${OS}/${CODENAME} ${URI}


if [[ $? -ne 0 ]]
then
    echo "Command 'debootstrap' exited with error."
    exit
fi


prepare_apt_source_list


tar -C /tmp/${OS}/${CODENAME} -c . | docker import - ${TAG}


rm -rf /tmp/${OS}

