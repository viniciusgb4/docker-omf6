#!/usr/bin/env bash

install_docker() {

    if [ "$(ls -A /etc/apt/sources.list.d/docker.list)" ]; then
        rm -rf /etc/apt/sources.list.d/docker.list
    fi

    apt-get install -y --force-yes apt-transport-https ca-certificates
    apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

    echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list

    apt-get update \
    && apt-get purge -y --force-yes lxc-docker \
    && apt-cache policy docker-engine \
    && apt-get install -y --force-yes linux-image-extra-$(uname -r) \
    && apt-get install -y --force-yes apparmor \
    && apt-get install -y --force-yes docker-engine \
    && service docker start
}

install_docker_compose() {
    curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
}

main() {
    install_docker
    install_docker_compose
}