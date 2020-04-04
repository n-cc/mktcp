#!/bin/sh
NICK=user12345
CTL=`mktemp -d`

send(){
	echo "$@" >> $CTL/in
}

PID=`sh ../mktcp.sh -s irc.freenode.net -p 6667 -d $CTL`
send "NICK $NICK"
send "USER $NICK"
while read line; do
	if grep -q PING <<< $line; then
		send "PONG"
	fi
< $CTL/out

kill $PID
