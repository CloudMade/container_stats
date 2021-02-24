# container_stats

Script to measure the total CPU utilization and RAM usage of Docker container.

## Usage

Execute on a docker host environment, where container is located which you are
planning to measure:

```
$ container_stats.sh <container_name> [<interval for collection (seconds)>]
```

Default interval is 0.1 second.


On run script will:

1. Wait for container to start if it is not running or stopped.
2. Copy one AWK script into container. It is used to pre-process the collected metrics.
3. Collect stats for CPU utilization in the system.
4. Collect stats for memory usage for all processes inside the container except bash, awk, date, head. Could be an issue if your process is bash, update the script accordingly.
5. On container stop or Ctrl-C, postprocess the collected metrics and output them in CSV format to stdout.
6. Remove the AWK script from container (copied on step 2).

## Output format

Example of the produced CSV:

```
timestamp_ms,cpu_percent,mem_usage_bytes
1614167079867,50,700416
1614167079971,50,700416
1614167080076,54.5455,700416
```

## Notes

- Increased frequency of collection (smaller values for the interval) will show more spikes in CPU consumption.
- It will also mean that the measurement script itself consumes more CPU.
- cgroups info which is used by `docker stats` command does not always produce the reliable results according to our experiments.
