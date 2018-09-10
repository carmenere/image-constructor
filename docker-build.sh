continue_with_defaults () {
    echo "Do you wish to continue script with defaults ($1)?"
    select YN in "Yes" "No"; do
      case ${YN} in
        "Yes" ) break;;
        "No" ) exit;;
      esac
    done
}


if [[ $# -eq 0 ]]
then
    echo "ERROR: No arguments supplied!"
    echo ""
    echo "Usage: ${0##*/} SOURCE_IMAGE_tag TARGET_IMAGE_tag"
    continue_with_defaults "ubuntu/bionic:18.04-minbase polygon:initial"
    SOURCE_TAG="ubuntu/bionic:18.04-minbase"
    TARGET_TAG="polygon:initial"

elif [[ $# -ne 2 ]]
then
    echo "ERROR: Incorrect arguments value supplied!"
    echo ""
    echo "Usage: ${0##*/} SOURCE_IMAGE_tag TARGET_IMAGE_tag"
    continue_with_defaults "ubuntu/bionic:18.04-minbase polygon:initial"
    SOURCE_TAG="ubuntu/bionic:18.04-minbase"
    TARGET_TAG="polygon:initial"

else
  if [[ -n "$1" ]]; then
      SOURCE_TAG=$1
  else
      SOURCE_TAG="ubuntu/bionic:18.04-minbase"
  fi

  if [[ -n "$2" ]]; then
      TARGET_TAG=$2
  else
      TARGET_TAG="polygon:initial"
  fi
fi


if [[ -e /tmp/docker-build ]]; then
  rm -rf /tmp/docker-build
fi

mkdir -p /tmp/docker-build

truncate -s 0 /tmp/docker-build/Dockerfile


################
# DECLARE VARS #
################
_LOCALE_='/etc/default/locale'
_PASSWD_="1"
_USER_="blackswan"
_SECRET_="$(echo $(openssl passwd -1 ${_PASSWD_}) | sed 's/\$/\\$/g')"

cat <<EOF > /tmp/docker-build/Dockerfile
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

##########################################################################
#   Common-base
##########################################################################
#RUN apt update && \
#    apt upgrade -y && \
#    apt clean
#
#RUN apt install -y locales && \
#    apt install -y iproute2 && \
#    apt install -y dnsutils && \
#    apt install -y scapy && \
#    apt install -y bash-completion && \
#    apt install -y openssl && \
#    apt install -y nano && \
#    apt install -y sudo && \
#    apt install -y nmap && \
#    apt install -y netcat-openbsd && \
#    apt install -y zip && \
#    apt install -y unzip && \
#    apt install -y git && \
#    apt install -y curl && \
#    apt install -y tcpdump && \
#    apt install -y openssh-server && \
#    apt install -y tree && \
#    apt clean
#
#
#RUN service ssh start
#
#RUN sed -i '\/etc\/bash_completion/s/^#//'  /root/.bashrc && \
#    sed -i '/\. \/etc\/bash_completion/afi' /root/.bashrc
#
#RUN sed -i '/PermitRootLogin/cPermitRootLogin no' /etc/ssh/sshd_config
#
#RUN useradd -p "${_SECRET_}" -s /bin/bash -m ${_USER_} && \
#    usermod -a -G sudo ${_USER_}
#
#RUN locale-gen ru_RU.UTF-8 && \
#    locale-gen en_US.UTF-8 && \
#    update-locale && \
#    echo 'LANG="en_US.UTF-8"' > ${_LOCALE_} && \
#    echo 'LC_TIME="ru_RU.UTF-8"' >> ${_LOCALE_}
#
#
##########################################################################
#   Scrapper, Backend
##########################################################################
#RUN apt install -y python3-dev && \
#    apt install -y python3-yaml && \
#    apt install -y python3-pip && \
#    apt install -y python3-setuptools && \
#    apt install -y python3-virtualenv && \
#    python3 -m pip install --upgrade pip setuptools && \
#    apt clean
#
#
#
##########################################################################
#   Frontend
##########################################################################
#RUN apt install -y nginx && \
#    apt clean
#
#
##########################################################################
#   DB
##########################################################################
#RUN apt install -y postgresql && \
#    apt clean
#
#
##########################################################################
#   Jupyter
##########################################################################
#RUN apt install -y python3-dev && \
#    apt install -y python3-yaml && \
#    apt install -y python3-pip && \
#    apt install -y python3-setuptools && \
#    apt install -y python3-virtualenv && \
#    apt install -y python3-numpy && \
#    apt install -y python3-scipy && \
#    apt install -y python3-pandas && \
#    apt install -y ipython3 && \
#    python3 -m pip install --upgrade pip setuptools && \
#    python3 -m pip install jupyter && \
#    apt clean
#

#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["/usr/sbin/sshd", "-D"]

EOF

docker build --no-cache -f /tmp/docker-build/Dockerfile /tmp --tag "${TARGET_TAG}"


rm -rf /tmp/docker-build
