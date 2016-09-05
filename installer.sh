#!/usr/bin/env bash

CONTROL_NETWORK_IP="10.0.0.200"
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

set_service_interface() {
    oldIFS=$IFS

    while read line; do
        IFS='=' read -r -a array <<< "$line"
        if [[ ${array[0]} = *"control_network"* ]]; then
            CONTROL_NETWORK_INTERFACE=${array[1]}
        fi
        IFS=$'n'
    done < $INSTALLER_HOME/conf/interface-network-map.conf
    IFS=$old_IFS
}

set_ips() {
    set_service_interface

    CONTROL_NETWORK_IP=$(/sbin/ifconfig $CONTROL_NETWORK_INTERFACE | grep 'inet end.:' | cut -d: -f2 | awk '{ print $1}')

    if [ -z "$CONTROL_NETWORK_IP" -o "$CONTROL_NETWORK_IP" == " " ]; then
        CONTROL_NETWORK_IP=$(/sbin/ifconfig $CONTROL_NETWORK_INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
    fi

    IP_BASE_DHCP_RANGE=$(echo $CONTROL_NETWORK_IP | cut -d"." -f1-3)
}

configure_bridge() {

    # Delete the IP address from eth1
    ip addr del $CONTROL_NETWORK_IP/16 dev eth1

    # Create "shared_nw" with a bridge name "docker1"
    docker network create \
        --driver bridge \
        --subnet=$IP_BASE_DHCP_RANGE.1/16 \
        --opt "com.docker.network.bridge.name"="docker_fibre" \
        fibre_nw
    # Add docker1 to eth1
    brctl addif docker_fibre eth1
}

main() {
    install_dependencies
    configure_bridge
    install_docker
    install_docker_compose
}

main

#docker run --name container1 --net fibre_nw --ip 10.0.0.200 -dt ubuntu