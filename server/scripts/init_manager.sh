#!/usr/bin/env bash
command="docker swarm  init --advertise-addr $1 --listen-addr $1:2377";
eval "$command";
echo $command;
