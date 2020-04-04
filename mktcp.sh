#!/bin/sh
CTL="$PWD/ctl"
CTLIN="$CTL/in"
CTLOUT="$CTL/out"
CREATEDCTL=0

usage(){
	echo "usage: $(basename $0) -s server -p port"
	echo "optional options:"
	echo "-d dir .. control dir (default $PWD/ctl)"
	exit $1
}

try(){
	$@
	if test $? -ne 0; then
		exit 1
	fi
}

cleanup(){
	rm -f $CTLIN $CTLOUT
	if test $CREATEDCTL -eq 1; then
		rmdir $CTL
	fi
}

init(){
	if test -z "$SERVER" || test -z "$PORT"; then
		usage 1
	fi
	if ! test -d "$CTL"; then
		CREATEDCTL=1
	fi
	try mkdir -p $CTL
	trap cleanup EXIT
	mkfifo $CTLIN 2>/dev/null
	mkfifo $CTLOUT 2>/dev/null
}

main(){
	init
	echo $$
	try nc $SERVER $PORT < $CTLIN > $CTLOUT
}

while getopts "s:p:d:h" opt; do
	case $opt in
		s) SERVER="$OPTARG" ;;
		p) PORT="$OPTARG"   ;;
		d) CTL="$OPTARG"    ;;
		h) usage 0	    ;;
		*) usage 1	    ;;
	esac
done

main
