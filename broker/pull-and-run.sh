#!/bin/bash

echo "Updating omf_sfa code"
git pull origin master

echo "Executing omf_sfa"
bundle exec ruby -I lib lib/omf-sfa/am/am_server.rb start &> /var/log/omf-sfa.log &

echo "Executing NITOS Testbed RCs"

user_proxy &> /var/log/ntrc/user_proxy.log &
frisbee_proxy &> /var/log/ntrc/frisbee_proxy.log &
cm_proxy &> /var/log/ntrc/cm_proxy.log &

sleep 5s
/root/omf_sfa/bin/create_resource -t node -c /root/omf_sfa/bin/conf.yaml -i /root/resources.json

tail -f /var/log/omf-sfa.log