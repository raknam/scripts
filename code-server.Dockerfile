FROM linuxserver/code-server:latest

LABEL org.opencontainers.image.authors="me@raknam.fr"

RUN apt-get update
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y ppa:ondrej/php
RUN apt-get update
RUN apt-get -y install php7.4-cli php7.4-curl php7.4-sqlite3

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

RUN apt-get install -y nodejs
RUN npm install -g npm
RUN npm install -g @google/clasp
