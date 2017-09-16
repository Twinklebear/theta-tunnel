#!/bin/bash

if [ "$1" == "-h" ]; then
	printf "Usage: ./theta-tunnel.sh <user name> <worker id> <port>\n\n"
	printf "\tThe script will tunnel the local port <port> through\n"
	printf "\tto a connection on Theta compute node nid<worker id>:<port>\n"
	printf "\tallowing you to connect to a remote running vis client.\n"
	printf "\tYou should enter the worker id without any leading zeros.\n"
	exit 0
fi

USER=$1
WORKER_ID=`printf "%05d" $2`
PORT=$3

ssh -L $PORT:localhost:$PORT ${USER}@theta.alcf.anl.gov <<-1
	echo "Opening tunnel to mom node ..."
	ssh -L $PORT:localhost:$PORT thetamom1 <<-2
		echo "Opening socat to nid${WORKER_ID}:${PORT} ..."
		socat TCP-LISTEN:$PORT,reuseaddr TCP:nid${WORKER_ID}:$PORT
	2
1

