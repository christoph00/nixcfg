package main

import (
	"fmt"
	"os"

	"github.com/christoph00/mqtt-host-agent/internal/agent"
)

func main() {
    if len(os.Args) != 2 {
        fmt.Println("Usage: mqtt-host-agent <config-file>")
        os.Exit(1)
    }

    agent, err := agent.New(os.Args[1])
    if err != nil {
        fmt.Printf("Error initializing agent: %v\n", err)
        os.Exit(1)
    }

    agent.Start()
    select {}
}
