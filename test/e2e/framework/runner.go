package framework

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
)

func ExecCommand(args ...string) error {
	fmt.Printf("Running command netctl: %v\n", strings.Join(args, " "))
	// TODO： ../../_output/bin/linux/amd64/netctl
	cmd := exec.Command("../../_output/bin/linux/amd64/netctl", strings.Join(args, " "))

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
