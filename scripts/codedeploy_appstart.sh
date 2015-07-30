#!/bin/sh -e

source ${0%/*}/_codedeploy.sh

if [ ! -p $APP_TEMP/syslog.out ] && [ ! -p $APP_TEMP/syslog.err ]; then
  echo "Creating syslog fifos."
  mkfifo $APP_TEMP/syslog.out
  mkfifo $APP_TEMP/syslog.err
  nohup logger -p daemon.info -t yesod-hello -f $APP_TEMP/syslog.out &
  nohup logger -p daemon.err -t yesod-hello -f $APP_TEMP/syslog.err &
fi

nohup $WEBSERVER_BIN 2>syslog.err >syslog.out &
WEBSERVER_PID=$!
echo "Started server at pid $WEBSERVER_PID."

echo $WEBSERVER_PID > $WEBSERVER_PIDFILE
