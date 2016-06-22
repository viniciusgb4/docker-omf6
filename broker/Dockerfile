FROM ubuntu:14.04

ENV OMF_SFA_HOME=/root/omf_sfa
ENV DOMAIN=ufg.br
ENV AM_SERVER_DOMAIN=ufg.br
ENV XMPP_DOMAIN=ufg.br

#PULL FROM GIT HUB AND RUN BROKER
COPY pull-and-run.sh /usr/bin/
ENTRYPOINT ["/usr/bin/pull-and-run.sh"]

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

WORKDIR /root

#BEGIN BROKER DOWNLOAD E INSTALATION
RUN git clone https://github.com/viniciusgb4/omf_sfa.git \
&& cd $OMF_SFA_HOME && bundle install
#END BROKER DOWNLOAD E INSTALATION

#BEGIN DATABASE CONFIGURATION
WORKDIR $OMF_SFA_HOME
RUN rake db:migrate
#END DATABASE CONFIGURATION

#BEGIN CERTIFICATES CONFIGURATION
RUN mkdir -p /root/.omf/trusted_roots
RUN omf_cert.rb --email root@$DOMAIN -o /root/.omf/trusted_roots/root.pem --duration 50000000 create_root \
&& omf_cert.rb -o /root/.omf/am.pem  --geni_uri URI:urn:publicid:IDN+$AM_SERVER_DOMAIN+user+am --email am@$DOMAIN --resource-id xmpp://am_controller@$XMPP_DOMAIN --resource-type am_controller --root /root/.omf/trusted_roots/root.pem --duration 50000000 create_resource \
&& omf_cert.rb -o /root/.omf/user_cert.pem --geni_uri URI:urn:publicid:IDN+$AM_SERVER_DOMAIN+user+root --email root@$DOMAIN --user root --root /root/.omf/trusted_roots/root.pem --duration 50000000 create_user

#RUN mkdir -p /root/.omf/trusted_roots && cp * /root/.omf/ && cp root.pem am.pem /root/.omf/trusted_roots/
RUN openssl rsa -in /root/.omf/am.pem -outform PEM -out /root/.omf/am.pkey \
&& openssl rsa -in /root/.omf/user_cert.pem -outform PEM -out /root/.omf/user_cert.pkey
#END CERTIFICATES CONFIGURATION

EXPOSE 8001/tcp

#BEGIN CONFIGURE BROKER STARTUP SERVICE
WORKDIR $OMF_SFA_HOME
RUN cp init/omf-sfa.conf /etc/init/ && sed -i '/chdir \/root\/omf\/omf_sfa/c\chdir \/root\/omf_sfa' /etc/init/omf-sfa.conf
#END CONFIGURE BROKER STARTUP SERVICE

#BEGIN CONFIGURE NITOS_RCS
RUN gem install nitos_testbed_rc \
&& install_ntrc

#BEGIN COPY CONFIGURATION FILE
COPY config-files /
#END COPY CONFIGURATION FILE

WORKDIR $OMF_SFA_HOME

##BEGIN CONFIGURE NITOS_RCS CERTIFICATES
RUN omf_cert.rb -o /root/.omf/user_factory.pem --email user_factory@$DOMAIN --resource-type user_factory --resource-id xmpp://user_factory@$XMPP_DOMAIN --root /root/.omf/trusted_roots/root.pem --duration 50000000 create_resource \
&& omf_cert.rb -o /root/.omf/cm_factory.pem --email cm_factory@$DOMAIN --resource-type cm_factory --resource-id xmpp://cm_factory@$XMPP_DOMAIN --root /root/.omf/trusted_roots/root.pem --duration 50000000 create_resource \
&& omf_cert.rb -o /root/.omf/frisbee_factory.pem --email frisbee_factory@$DOMAIN --resource-type frisbee_factory --resource-id xmpp://frisbee_factory@$XMPP_DOMAIN --root /root/.omf/trusted_roots/root.pem --duration 50000000 create_resource
##END CONFIGURE NITOS_RCS CERTIFICATES

#COPY nitos_rcs/* /etc/nitos_testbed_rc/
RUN cp -r /root/.omf/trusted_roots/ /etc/nitos_testbed_rc/
#END CONFIGURE NITOS_RCS

#BEGIN CONFIGURE PXE
#COPY pxe-config /
RUN ln -s /usr/lib/syslinux/pxelinux.0 /tftpboot/ \
&& ln -s omf-5.4 01-00:03:1d:0c:23:46 \
&& ln -s omf-5.4 01-00:03:1d:0c:47:48 \
&& cat /root/dnsmasq.conf >> /etc/dnsmasq.conf
