## Completed features
 - `ps -ef` (needs validation)
 - `lsof` (needs validation)
 - prevent containerized root from killing other processes
 - prevent containerized root from affecting users list
 - recursive mounts are read-only (when using bindfs)
 - unbindable mounts do show up (when using bindfs)
 - `top, free` memory/cpu resources
 - hardware info via `lscpu, lspci, lsusb` etc.
 - sysstat tools
	- `sar -u -o /tmp/datafile 2 3` (writes results to terminal and outputs binary data in executable tmpfs)
	- `pidstat`

## Known limitations
 - maskedPaths prevents paths like `/proc/timer_stats` from being read, cannot do `echo 0 > /proc/timer_stats`
