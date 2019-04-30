package main

import (
	"fmt"
	"os"
	"os/signal"

	"github.com/bjia56/procfs"
)

func main() {
	fmt.Println("my pid:", os.Getpid())
	signal.Ignore(os.Interrupt)

	hostFs, err := procfs.NewFS(procfs.DefaultMountPoint)
	if err != nil {
		panic(err)
	}

	contFs, err := procfs.NewFS("/tmp/.proc")
	if err != nil {
		panic(err)
	}

	procs, err := hostFs.AllProcs()
	if err != nil {
		panic(err)
	}

	for _, proc := range procs {
		p, err := os.FindProcess(proc.PID)
		if err != nil {
			fmt.Println("skpping PID", proc.PID)
			continue
		}
		comm, err := proc.Comm()
		if err != nil {
			fmt.Println("skipping PID", proc.PID)
			continue
		}

		err = p.Signal(os.Interrupt)
		if err != nil {
			fmt.Println("cannot interrupt PID", proc.PID, "due to error:", err)
		} else {
			var contComm = "(cannot find container comm)"
			cProc, err := contFs.NewProc(proc.PID)
			if err == nil {
				cc, err := cProc.Comm()
				if err == nil {
					contComm = cc
				}
			}
			fmt.Println("interrupted PID", proc.PID, "host:", comm, "container:", contComm)
		}
	}
}
