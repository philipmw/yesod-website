#!/bin/sh

TRY=0
RETCODE=1

while [ $TRY -lt 10 ] && [ $RETCODE -ne 0 ]; do
  TRY=$(($TRY + 1))
  stack build
  RETCODE=$?
done

echo "Done on try $TRY with return code $RETCODE"
exit $RETCODE
