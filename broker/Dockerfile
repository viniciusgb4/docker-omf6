FROM ubuntu:14.04

ENV OMF_SFA_HOME=/root/omf_sfa
ENV OMF_CERTS_HOME=/root/.omf
ENV DOMAIN=ufg.br
ENV AM_SERVER_DOMAIN=ufg.br
ENV XMPP_DOMAIN=ufg.br

RUN echo 'deb http://pkg.mytestbed.net/ubuntu precise/ ' >> /etc/apt/sources.list \
&& apt-get update
RUN apt-get install -y --force-yes \
   build-essential \
   dnsmasq \
   frisbee \
   git \
   libsqlite3-dev \
   libreadline6-dev \
   libssl-dev \
   libxmlsec1-dev \
   libyaml-dev \
   ntp \
   #ruby-dev \
   syslinux \
   xmlsec1 \
   wget \
   zlib1g-dev

RUN cd /tmp \
   && wget http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz \
   && tar -xvzf ruby-2.1.5.tar.gz \
   && cd ruby-2.1.5/ \
   && ./configure --prefix=/usr/local \
   && make \
   && make install \
   && rm -rf /tmp/ruby

RUN gem install bundler --no-ri --no-rdoc

EXPOSE 8001/tcp

#BEGIN COPY CONFIGURATION FILE
COPY config-files /root/config-files/
#END COPY CONFIGURATION FILE

#PULL FROM GIT HUB AND RUN BROKER
COPY pull-and-run.sh /usr/bin/
ENTRYPOINT ["/usr/bin/pull-and-run.sh"]