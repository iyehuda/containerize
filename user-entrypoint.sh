#!/bin/sh

set -e

PATH='/bin:/usr/bin:/usr/local/bin'
CONTAINER_NAME=$(cat /dev/urandom | tr -dc 'a-f0-9' | fold -w64 | head -n 1)

cat ~/message

# check whether TIMEOUT is an integer
if echo $TIMEOUT | grep -Eq '^[+-]?[0-9]+$'; then
  (sleep $TIMEOUT && echo -e "$TIMEOUT_MESSAGE \r" && docker rm -fv ${CONTAINER_NAME} > /dev/null) &
fi

docker run --name $CONTAINER_NAME "$@"
