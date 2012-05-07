#!/bin/bash

RETVAL=0

for s in /chapter0${1}/*sh
do
  if [ -x $s ]
  then
      bash -xe $s
      RETVAL=$?
  fi
  case $RETVAL in
    0)
      chmod -x $s
      ;;
    *)
      echo "$s failed ! >&2"
      exit 1
      ;;
  esac
done
