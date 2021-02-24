#!/usr/bin/awk -f

# Copyright (c) 2021 CloudMade
# Maintainer: omarkov@cloudmade.com
#
# Script to preprocess metrics collected for CPU and Memory by the
# container_stats.sh
#
# Expected input:
# date +%s%3N && head -n1 /proc/stat && ps axo rss,command --no-header
#
# Idea how to calculate CPU metrics is described here:
# https://rosettacode.org/wiki/Linux_CPU_utilization

BEGIN {
    OFS=","
    memory=0
}

# catch timestamp (ms) on a first line: date +%s%3N
NR==1 {timestamp=$1}

# catch CPU time on a second line: head -n1 /proc/stat
NR==2 {
    cpu_idle = $5
    cpu_total = 0

    for (i = 2; i <= NF; i++)
        cpu_total += $i
}

# Calculate total for memory (kb) collected from "ps" output
NR>2 && !/ps axo|awk|bash|date|head/ {memory += $1}

END {print timestamp, cpu_idle, cpu_total, memory}
