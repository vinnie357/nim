#!/bin/bash
# # start nim agent if fqdn is set
# /bin/su -s /bin/bash -c '/usr/sbin/nginx-agent &' nginx
# # start nginx
# /usr/sbin/nginx -g 'daemon off;'
# turn on bash's job control
set -m

# Start the primary process and put it in the background
/usr/sbin/nginx -g 'daemon off;' &

# Start the helper process
#./nginx-agent
sleep 5 && /usr/sbin/nginx-agent

# now we bring the primary process back into the foreground
# and leave it there
fg %1
