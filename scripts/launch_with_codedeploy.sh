#!/bin/sh

cd /opt/yesod-website
mkfifo syslog.out
mkfifo syslog.err

nohup logger -p daemon.info -t yesod-hello -f syslog.out &
nohup logger -p daemon.err -t yesod-hello -f syslog.err &
nohup /opt/yesod-website/yesod-website 2>syslog.err >syslog.out &
