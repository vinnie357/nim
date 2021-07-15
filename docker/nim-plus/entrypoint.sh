#!/bin/bash
# turn on bash's job control
set -m

# Start the primary process and put it in the background
/usr/sbin/nginx -g 'daemon off;' &
# start nim
/usr/sbin/nginx-manager &
# Start the helper process
#./nginx-agent
/usr/sbin/nginx-agent

# now we bring the primary process back into the foreground
# and leave it there
fg %1
