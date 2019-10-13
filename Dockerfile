############################################################
# Trobz's Ubuntu 14.04 base image
############################################################

FROM ubuntu:14.04

# disable interactive debconf mode
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install all dependencies
############################################################

COPY config/apt/sources.14.04.list /etc/apt/sources.list
COPY config/apt/apt.conf.d /etc/apt/apt.conf.d

# Linux command line tools
RUN apt-get update && apt-get -qq -y dist-upgrade && \
    apt-get install -qq -y sudo openssh-server supervisor aptitude apt-transport-https \
    dnsutils net-tools mtr-tiny nmap ngrep telnet traceroute iputils-ping netstat-nat \
    htop ncdu nano lynx vim-nox zsh bash-completion screen tig tmux lftp apt-utils \
    wget curl git-core locate man rsync build-essential make gcc keychain \
    dialog locales software-properties-common python-software-properties && \
    rm -rf /var/lib/apt/lists/*

# Configure timezone and locale
RUN echo "Asia/Ho_Chi_Minh" > /etc/timezone; dpkg-reconfigure -f noninteractive tzdata
RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

# Set locale environment
COPY config/user/locale /etc/default/locale
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Install Trobz's certificates by default
COPY config/cert/bundle.crt /usr/local/share/ca-certificates/trobz_bundle.crt
COPY config/cert/trobz.crt /usr/local/share/ca-certificates/trobz.crt
RUN update-ca-certificates

# sudo
COPY config/user/sudoers /etc/sudoers
RUN chmod 0440 /etc/sudoers

# bash shell
COPY config/user/bash.bashrc /tmp/setup/user/bash.bashrc
COPY config/user/skel /etc/skel
COPY scripts/common /etc/bash
COPY scripts/bash /etc/bash.d

# vim
ADD config/vim/vim.tar.gz /tmp/setup

# supervisor
COPY config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/run/supervisor
RUN mkdir -p /var/log/supervisor

# sshd
RUN mkdir /var/run/sshd
RUN chmod 0755 /var/run/sshd
# configure ssh server service with supervisord
COPY config/supervisor/conf.d/sshd.conf /etc/supervisor/conf.d/sshd.conf

# install latest git from launchpad ppa
COPY scripts/setup/git.sh /tmp/setup/git/git.sh
RUN /bin/bash < /tmp/setup/git/git.sh

RUN mkdir -p /var/log/docker
RUN chmod a+rw /var/log/docker -R

COPY scripts/start /usr/local/docker/start
RUN chmod +x /usr/local/docker/start -R

# Finalization
############################################################

VOLUME ["/var/log/docker"]

ENV USERNAME docker
ENV PASSWORD docker
ENV USER_UID 1000
ENV USER_GID 1000
ENV USER_HOME /home/docker

ONBUILD RUN apt-get update
ONBUILD RUN apt-get dist-upgrade -y
ONBUILD RUN updatedb

EXPOSE 22 8011

# USER root
CMD [ "/usr/local/docker/start/main.sh" ]

############################################################
# Supervisord service
############################################################

# FROM  trobz/ubuntu:14.04

# Install common dependencies
############################################################

RUN apt-get install -y supervisor

# supervisor

COPY config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
RUN mkdir -p /var/run/supervisor
RUN mkdir -p /var/log/supervisor

# Finalization
############################################################

VOLUME ["/var/log/supervisor"]

EXPOSE 8011

ONBUILD RUN apt-get update
ONBUILD RUN apt-get upgrade -y
ONBUILD RUN updatedb

# configure supervisord
ADD scripts/start/init/05_supervisord.sh /usr/local/docker/start/init/05_supervisord.sh

# run supervisord
ADD scripts/start/run.sh /usr/local/docker/start/run.sh

############################################################
# SSH server
############################################################

# FROM trobz/supervisord:14.04

# Install common dependencies
############################################################

RUN apt-get install -y \
    git curl wget net-tools lynx nano htop screen \
    sudo openssh-server

# screen

RUN chmod 0777 /var/run/screen

# vim

ADD config/vim/vim.tar.gz /tmp/setup

# # ssh

# RUN mkdir /var/run/sshd
# RUN chmod 0755 /var/run/sshd

# # configure ssh server service with supervisord
# COPY config/supervisor/sshd.conf /etc/supervisor/conf.d/sshd.conf

# Finalization
############################################################

EXPOSE 22

ONBUILD RUN apt-get update
ONBUILD RUN apt-get upgrade -y
ONBUILD RUN updatedb

ADD scripts/start/init/05_ssh.sh /usr/local/docker/start/init/05_ssh.sh
ADD scripts/start/init/06_vim.sh /usr/local/docker/start/init/06_vim.sh

############################################################
# Fullstack OpenERP 8.0 server
############################################################

# FROM trobz/sshd:14.04

# Prepare for the setup 
############################################################

RUN apt-get update
RUN apt-get install -y postgresql postgresql-contrib-9.3
RUN apt-get update && apt-get dist-upgrade -y

# Install all services
############################################################

# Common lib
ADD scripts/setup/common /tmp/setup/common
RUN /bin/bash < /tmp/setup/common/deps.sh
# OpenOffice + Aeroo
ADD scripts/setup/odoo /tmp/setup/odoo
RUN /bin/bash < /tmp/setup/odoo/deps.sh

# Configure all services
############################################################

# postgresql

ADD config/postgres/ /etc/postgresql/docker/defaults
RUN chown postgres: /etc/postgresql/docker -R

# supervisor

ADD config/supervisor/postgres.conf /etc/supervisor/conf.d/postgres.conf

# update locate db
RUN updatedb

# change default user configuration
ENV USERNAME openerp
ENV PASSWORD openerp
ENV USER_HOME /opt/openerp

# Add odoo 8.0 demo files
############################################################

ADD demo /tmp/setup/odoo/demo

# Finalization
############################################################

# expose openerp/postgres port
EXPOSE 8069 5432 22

# enable interactive debconf again
RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

ADD scripts/start/init/20_postgres.sh /usr/local/docker/start/init/20_postgres.sh
ADD scripts/start/init/25_virtual_env.sh /usr/local/docker/start/init/25_virtual_env.sh
