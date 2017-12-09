#!/usr/bin/env bash
keyscan_command="ssh-keyscan -H -p $2 $1";

while ! nc -z $1 $2; do
  echo "waiting for $1 $2";
  sleep 1 # wait for 1 second before check again
done
eval $keyscan_command;
