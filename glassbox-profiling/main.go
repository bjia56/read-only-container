package main

import (
	"fmt"
	"os"
	"time"

	"github.com/bjia56/procfs"
)

var fs procfs.FS
var startTime int64

func main() {
	if len(os.Args) != 2 {
		panic(fmt.Sprintf("usage: %s <program name>", os.Args[0]))
	}

	var err error
	fs, err = procfs.NewFS(procfs.DefaultMountPoint)
	if err != nil {
		panic(err)
	}

	pid := -1
	for {
		pid = findProcess(os.Args[1])
		if pid != -1 {
			break
		}
	}

	startTime = time.Now().UnixNano()
	fmt.Printf("%s,%s,%s\n", "Time ms", "Process:PID", "RSS KB")
	for {
		_, err = fs.NewProc(pid)
		if err != nil {
			break
		}
		printAllOffspring(pid)
	}
}

func findProcess(name string) int {
	procs, err := fs.AllProcs()
	if err != nil {
		panic(err)
	}

	for _, proc := range procs {
		comm, err := proc.Comm()
		if err != nil {
			continue
		}
		if comm == name {
			return proc.PID
		}
	}

	return -1
}

func printAllOffspring(pid int) {
	p, err := fs.NewProc(pid)
	if err != nil {
		return
	}

	s, err := p.NewStat()
	if err != nil {
		return
	}

	fmt.Printf("%d,%s:%d,%d\n", (time.Now().UnixNano() - startTime) / 1000000, s.Comm, s.PID, s.ResidentMemory() / 1024)

	children, err := p.Children()
	if err != nil {
		return
	}

	for _, child := range children {
		printAllOffspring(child)
	}
}
