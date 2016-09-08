#!/usr/bin/env bash

CONTROL_NETWORK_IP="10.0.0.200"
CM_NETWORK_IP="172.16.137.3"
IP_BASE_DHCP_RANGE="10.0.0"

install_dependencies() {
    apt-get update
    apt-get install -y --force-yes bridge-utils
}

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

configure_control_bridge() {

    # Delete the IP address from eth1
    ip addr del $CONTROL_NETWORK_IP/16 dev eth1

    # Create "shared_nw" with a bridge name "docker1"
    docker network create \
        --driver bridge \
        --subnet=$IP_BASE_DHCP_RANGE.0/16 \
        --opt "com.docker.network.bridge.name"="control_bridge" \
        --opt "com.docker.network.bridge.host_binding_ipv4"="10.0.0.200" \
        fibre_nw
    # Add docker1 to eth1
    brctl addif docker_fibre eth1
}

configure_cm_bridge() {

    # Delete the IP address from eth1
    ip addr del $CONTROL_NETWORK_IP/24 dev eth2

    # Create "shared_nw" with a bridge name "docker1"
    docker network create \
        --driver bridge \
        --subnet=172.16.137.0/24 \
        --opt "com.docker.network.bridge.name"="cm_bridge" \
        --opt "com.docker.network.bridge.host_binding_ipv4"="172.16.137.2" \
        cm_nw
    # Add docker1 to eth1
    brctl addif cm_bridge eth2
}

main() {
    install_dependencies
    configure_control_bridge
    configure_cm_bridge
    install_docker
    install_docker_compose
}

main

#docker run --name container1 --net fibre_nw --ip 10.0.0.200 -dt ubuntu