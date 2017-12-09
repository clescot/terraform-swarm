#!/usr/bin/env bash
token=$2;
command="docker swarm join $1:2377 --token $token";
eval "$command";
echo $command;
