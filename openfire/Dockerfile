FROM viniciusbraga/omf6-openfire
MAINTAINER vinicius.esufg@gmail.com

ENV OPENFIRE_USER=openfire \
    OPENFIRE_DATA_DIR=/var/lib/openfire \
    OPENFIRE_LOG_DIR=/var/log/openfire

EXPOSE 3478/tcp 3479/tcp 5222/tcp 5223/tcp 5229/tcp 7070/tcp 7443/tcp 7777/tcp 9090/tcp 9091/tcp
VOLUME ["${OPENFIRE_DATA_DIR}"]