#!/bin/bash

########################################################################################
#   Selenium
#   Example: ./builder.sh ubuntu-18.04:py3dev ubuntu-18.04:selenium Dockerfile_selenium
########################################################################################

#Usage:
#from selenium import webdriver
#from selenium.webdriver.chrome.options import Options
#
#options = Options()
#options.add_argument('--headless')
#options.add_argument('--disable-gpu')
#options.add_argument('--no-sandbox')
#driver = webdriver.Chrome(chrome_options=options)

Dockerfile_selenium () {
local DOCKERFILE_DIR=$1
local SOURCE_TAG=$2

cat <<EOF > ${DOCKERFILE_DIR}/Dockerfile_selenium
FROM ${SOURCE_TAG}

ARG TERM=xterm-256color
ARG DEBIAN_FRONTEND=noninteractive

ENV TERM=xterm-256color

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt update && \
    apt install -y google-chrome-stable && \
    apt clean && \
    python3 -m pip install selenium && \
    wget https://chromedriver.storage.googleapis.com/2.43/chromedriver_linux64.zip  && \
    unzip chromedriver_linux64.zip  && \
    mv chromedriver /usr/bin/chromedriver && \
    chown root:root /usr/bin/chromedriver && \
    chmod +x /usr/bin/chromedriver

EOF

echo -n "${DOCKERFILE_DIR}/Dockerfile_selenium"

}

echo Dockerfile_selenium