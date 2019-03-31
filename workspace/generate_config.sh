#!/bin/bash

REAL_UID=$1
REAL_GID=$2
USR_PATH=$3
WORK_DIR=$4
ROOTFS=$5
DISPLAY_NUM=$6
HOSTNAME=$(/bin/hostname)
USR_HOME=$(/usr/bin/getent passwd "$REAL_UID" | /usr/bin/cut -d: -f6)

if [ -n "$DISPLAY_NUM" ]; then
    DISPLAY_ENV="\"DISPLAY=:$DISPLAY_NUM.0\","
    DISPLAY_MOUNT="{\"destination\":\"/tmp/.X11-unix\", \"source\":\"$WORK_DIR/.X11-unix\", \"options\":[\"bind\", \"rw\"]},"
fi

/bin/cat << EOF
{
    "hostname": "$HOSTNAME",
    "linux": {
        "maskedPaths": [
            "/proc/kcore",
            "/proc/latency_stats",
            "/proc/timer_list",
            "/proc/timer_stats",
            "/proc/sched_debug",
            "/sys/firmware",
            "/proc/scsi"
        ],
        "namespaces": [
            {
                "type": "pid"
            },
            {
                "type": "network"
            },
            {
                "type": "ipc"
            },
            {
                "type": "uts"
            },
            {
                "type": "mount"
            }
        ],
        "readonlyPaths": [
            "/proc/asound",
            "/proc/bus",
            "/proc/fs",
            "/proc/irq",
            "/proc/sys",
            "/proc/sysrq-trigger"
        ],
        "resources": {
            "devices": [
                {
                    "access": "rwm",
                    "allow": false
                }
            ]
        }
    },
    "mounts": [
        {
            "destination": "/proc",
            "source": "/proc",
            "options": [
                "bind",
                "ro"
            ]
        },
        {
            "destination": "/dev",
            "options": [
                "nosuid",
                "strictatime",
                "mode=755",
                "size=65536k"
            ],
            "source": "tmpfs",
            "type": "tmpfs"
        },
        {
            "destination": "/dev/pts",
            "options": [
                "nosuid",
                "noexec",
                "newinstance",
                "ptmxmode=0666",
                "mode=0620",
                "gid=5"
            ],
            "source": "devpts",
            "type": "devpts"
        },
        {
            "destination": "/dev/shm",
            "options": [
                "nosuid",
                "noexec",
                "nodev",
                "mode=1777",
                "size=65536k"
            ],
            "source": "shm",
            "type": "tmpfs"
        },
        {
            "destination": "/tmp",
            "options": [
                "nosuid",
                "nodev",
                "mode=1777",
                "size=65536k"
            ],
            "type": "tmpfs"
        },
        $DISPLAY_MOUNT
        {
            "destination": "/dev/mqueue",
            "options": [
                "nosuid",
                "noexec",
                "nodev"
            ],
            "source": "mqueue",
            "type": "mqueue"
        },
        {
            "destination": "/sys",
            "options": [
                "nosuid",
                "noexec",
                "nodev",
                "ro"
            ],
            "source": "sysfs",
            "type": "sysfs"
        },
        {
            "destination": "/sys/fs/cgroup",
            "options": [
                "nosuid",
                "noexec",
                "nodev",
                "relatime",
                "ro"
            ],
            "source": "cgroup",
            "type": "cgroup"
        }
    ],
    "ociVersion": "1.0.1-dev",
    "process": {
        "args": [
            "/bin/bash"
        ],
        "capabilities": {
            "ambient": [
                "CAP_AUDIT_WRITE",
                "CAP_SETGID",
                "CAP_SETUID",
                "CAP_NET_BIND_SERVICE"
            ],
            "bounding": [
                "CAP_AUDIT_WRITE",
                "CAP_SETGID",
                "CAP_SETUID",
                "CAP_NET_BIND_SERVICE"
            ],
            "effective": [
                "CAP_AUDIT_WRITE",
                "CAP_SETGID",
                "CAP_SETUID",
                "CAP_NET_BIND_SERVICE"
            ],
            "inheritable": [
                "CAP_AUDIT_WRITE",
                "CAP_SETGID",
                "CAP_SETUID",
                "CAP_NET_BIND_SERVICE"
            ],
            "permitted": [
                "CAP_AUDIT_WRITE",
                "CAP_SETGID",
                "CAP_SETUID",
                "CAP_NET_BIND_SERVICE"
            ]
        },
        "cwd": "$USR_HOME",
        "env": [
            $DISPLAY_ENV
            "PATH=$USR_PATH",
            "TERM=xterm",
            "SHELL=/bin/bash"
        ],
        "noNewPrivileges": true,
        "rlimits": [
            {
                "hard": 1024,
                "soft": 1024,
                "type": "RLIMIT_NOFILE"
            }
        ],
        "terminal": true,
        "user": {
            "gid": $REAL_GID,
            "uid": $REAL_UID
        }
    },
    "root": {
        "path": "$ROOTFS",
        "readonly": true
    }
}
EOF
