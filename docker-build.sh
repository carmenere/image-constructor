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
    echo "Usage: ${0##*/} FROM_image_tag NEW_image_tag"
    continue_with_defaults "ubuntu/bionic:18.04-minbase polygon:initial"
    TAG="ubuntu/bionic:18.04-minbase"
    TAG2="polygon:initial"

elif [[ $# -ne 2 ]]
then
    echo "ERROR: Incorrect arguments value supplied!"
    echo ""
    echo "Usage: ${0##*/} FROM_image_tag NEW_image_tag"
    continue_with_defaults "ubuntu/bionic:18.04-minbase polygon:initial"
    TAG="ubuntu/bionic:18.04-minbase"
    TAG2="polygon:initial"

else
  if [[ -n "$1" ]]; then
      TAG=$1
  else
      TAG="ubuntu/bionic:18.04-minbase"
  fi

  if [[ -n "$2" ]]; then
      TAG2=$2
  else
      TAG2="polygon:initial"
  fi
fi


if [[ -e /tmp/docker-build ]]; then
  rm -rf /tmp/docker-build
fi

mkdir -p /tmp/docker-build

truncate -s 0 /tmp/docker-build/Dockerfile

cat <<EOF > /tmp/docker-build/Dockerfile
FROM ${TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN apt update && \
    apt upgrade -y && \
    apt clean

#RUN apt install -y iproute2 && \
#    apt install -y scapy && \
#    apt install -y bash-completion && \
#    apt install -y nano && \
#    apt install -y sudo && \
#    apt install -y nmap && \
#    apt install -y zlib1g-dev && \
#    apt install -y libssl-dev && \
#    apt install -y zip && \
#    apt install -y unzip && \
#    apt install -y git && \
#    apt install -y strace && \
#    apt install -y ltrace && \
#    apt install -y curl && \
#    apt install -y build-essential && \
#    apt install -y conntrack && \
#    apt install -y ipset && \
#    apt install -y tcpdump && \
#    apt install -y openssh-server && \
#    apt install -y lshw && \
#    apt install -y htop && \
#    apt install -y tshark && \
#    apt install -y tree && \
#    apt install -y python3-dev && \
#    apt install -y python3-yaml && \
#    apt install -y python3-pip && \
#    apt install -y python3-setuptools && \
#    apt install -y python3-virtualenv && \
#    apt install -y python3-numpy && \
#    apt install -y python3-scipy && \
#    apt install -y python3-matplotlib && \
#    apt install -y python3-pandas && \
#    apt install -y ipython3 && \
#    pip3 install --upgrade pip setuptools && \
#    apt install -y nginx && \
#    apt install -y postgresql && \
#    apt clean

RUN apt install -y iproute2 && \
    apt install -y sudo && \
    apt install -y tcpdump && \
    apt install -y bash-completion && \
    apt install -y nano && \
    apt install -y git && \
    apt install -y curl && \
    apt install -y openssh-server && \
    apt install -y tree && \
    apt install -y python3-dev && \
    apt install -y python3-yaml && \
    apt install -y python3-pip && \
    apt install -y python3-setuptools && \
    apt install -y python3-virtualenv && \
    apt install -y python3-numpy && \
    apt install -y python3-scipy && \
    apt install -y python3-pandas && \
    apt install -y ipython3 && \
    pip3 install --upgrade pip setuptools && \
    apt clean

RUN service ssh start

RUN sed -i '\/etc\/bash_completion/s/^#//'  /root/.bashrc && \
    sed -i '/\. \/etc\/bash_completion/afi' /root/.bashrc

RUN sed -i '/PermitRootLogin/cPermitRootLogin yes' /etc/ssh/sshd_config

#RUN useradd -p $(openssl passwd -1 1) -m -G sudo blackswan

ENTRYPOINT ["/usr/sbin/sshd", "-D"]

EOF


docker build --no-cache -f /tmp/docker-build/Dockerfile /tmp --tag "${TAG2}"


rm -rf /tmp/docker-build