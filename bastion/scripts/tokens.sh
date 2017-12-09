#!/usr/bin/env bash
eval "> $5_token.txt";
command="ssh -o \"StrictHostKeyChecking no\" -J $2@$4:$3 -p $3 $2@$1 docker swarm join-token -q $5 ";

while ! nc -z $4 $3; do
  sleep 1 # wait for 1 second before check again
done

eval "$command" > $5_token.txt;
echo "$command";
