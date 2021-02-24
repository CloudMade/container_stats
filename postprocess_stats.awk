#!/usr/bin/awk -f

# Copyright (c) 2021 CloudMade
# Maintainer: omarkov@cloudmade.com
#
# Script to postprocess metrics collected for CPU and Memory by the
# container_stats.sh
#
# Expected input (CSV):
# timestamp_ms,cpu_idle,cpu_total,memory_kb
#
# Idea how to calculate CPU metrics is described here:
# https://rosettacode.org/wiki/Linux_CPU_utilization

BEGIN {
    FS = ","
    OFS = ","
    # header:
    print "timestamp_ms,cpu_percent,mem_usage_bytes"
}

# discard lines which doesn't start with a number
!/^[0-9]/ { next }

# discard first line, memorize cpu metrics to calculate deltas
NR==1 {
    prev_cpu_idle = $2
    prev_cpu_total = $3
}

# calculate CPU and format nice output
NR>1 {
    cpu_idle = $2
    cpu_total = $3

    diff_cpu_total = cpu_total - prev_cpu_total
    if (diff_cpu_total == 0)
        cpu = 0
    else
        cpu = (1 - (cpu_idle - prev_cpu_idle) / diff_cpu_total) * 100

    prev_cpu_idle = cpu_idle
    prev_cpu_total = cpu_total

    print $1, cpu, $4*1024
}
