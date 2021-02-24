#!/bin/sh

# container_stats 1.0
# Copyright (c) 2021 CloudMade
# Maintainer: omarkov@cloudmade.com

INTERVAL_SECONDS=0.1

if [ -z "$1" ]; then
    echo "Usage: $0 <container_name> [<interval for collection (seconds)>]"
    exit 1
fi

if [ -n "$2" ]; then
    INTERVAL_SECONDS=$2
fi

CONTAINER_NAME=$1

IS_CONTAINER_RUNNING=$(docker ps | grep "$CONTAINER_NAME")
if [ -z "$IS_CONTAINER_RUNNING" ]; then
    echo "Container \"$CONTAINER_NAME\" was not found or is stopped." >&2
    echo "Waiting for availability..." >&2

    while [ -z "$IS_CONTAINER_RUNNING" ]; do
        sleep 1
        IS_CONTAINER_RUNNING=$(docker ps | grep "$CONTAINER_NAME")
    done
fi


METRICS_FILE=$(mktemp)

postprocess() {
    if [ -s "$METRICS_FILE" ]; then
        echo "Postprocessing the collected stats (if any), please wait..." >&2
        echo "==============================================" >&2

        awk -f ./postprocess_stats.awk "$METRICS_FILE"

        echo "==============================================" >&2
        echo "Postprocessing finished!" >&2
    fi

    rm -f $METRICS_FILE
    echo "Temp file $METRICS_FILE was removed" >&2
}
trap postprocess EXIT

docker cp ./format_metrics.awk $CONTAINER_NAME:/

echo "Collecting metrics inside container $CONTAINER_NAME..." >&2
echo "You will not see any output until collection is finished." >&2
echo "These logs are on stderr, don't worry." >&2
echo "Use redirection to file to save the clean CSV." >&2
echo "" >&2
echo "Press Ctrl-C to finish collection" >&2

docker exec -ti $CONTAINER_NAME  bash -c "stty -ctlecho; while true; do (date +%s%3N && head -n1 /proc/stat && ps axo rss,command --no-header) | awk -f /format_metrics.awk; sleep $INTERVAL_SECONDS; done;" >$METRICS_FILE
docker exec -ti $CONTAINER_NAME rm -f /format_metrics.awk
