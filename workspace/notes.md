## Completed features
 - `ps -ef` (needs validation)
 - `lsof` (needs validation)
 - prevent containerized root from killing other processes
 - prevent containerized root from affecting users list

## Known limitations
 - recursive mounts may not be read-only (e.g. container can still write to /vagrant)
 - unbindable mounts likely do not show up
