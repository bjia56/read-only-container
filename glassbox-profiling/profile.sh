#!/bin/bash
renice -n -10 $$ > /dev/null

get_pid_descendants() {
    local CHILDREN=$(ps -o pid= --ppid "$1")

    for PID in $CHILDREN; do
        if [ "$PID" != "$$" ]; then
            get_pid_descendants "$PID"
        fi
    done

    echo "$CHILDREN"
}

sum_pid_memory() {
    local CHILDREN=$(get_pid_descendants $1)
    local MEMORY=0

    for PID in $CHILDREN; do
        # get process RSS
        TMP=$(pmap -x $PID | tail -n +2 | tail -n 1 | awk '{print $4}')
	if [ -n "$TMP" ]; then
            MEMORY=$(($MEMORY + $TMP))
        fi
    done

    echo $MEMORY
}

NO_PID=0
EXIT_UPPER_BOUND=200
while true; do
    TINI_PID=$(pidof $1)

    if [ -n "$TINI_PID" ]; then
        NO_PID=0
        sum_pid_memory $TINI_PID
    else
        NO_PID=$(($NO_PID + 1))

        if [ "$NO_PID" -gt "$EXIT_UPPER_BOUND" ]; then
	    break
        fi
    fi
done
