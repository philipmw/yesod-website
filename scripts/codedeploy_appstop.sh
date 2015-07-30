#!/bin/sh

source $ROOT_DIR/scripts/_codedeploy.sh

if [ -f $WEBSERVER_PIDFILE ]; then
  echo "Pidfile exists."
  WEBSERVER_PID=$(<$WEBSERVER_PIDFILE)
  echo "PID is $WEBSERVER_PID"
  kill $WEBSERVER_PID

  KILL_RETCODE=$?
  while [ $KILL_RETCODE -eq 0 ]; do
    echo "Waiting for web server to die."
    sleep 1
    kill -0 $WEBSERVER_PID
    KILL_RETCODE=$?
  done

  echo "Killed the server."
  rm -f $WEBSERVER_PIDFILE
fi
