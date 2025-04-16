package main

import (
	"bufio"
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"time"
)

const defaultOutput = "prompt.txt"

func main() {
	flag.Usage = func() {
		fmt.Printf("Usage: %s <directory|laravel-app> [output-filename]\n", os.Args[0])
	}

	outputFile := flag.String("o", defaultOutput, "Output filename")
	flag.Parse()

	args := flag.Args()
	if len(args) != 1 {
		flag.Usage()
		os.Exit(1)
	}

	dirs := getDirs(args[0])
	validateDirs(dirs)

	output, err := os.Create(*outputFile)
	if err != nil {
		fmt.Printf("Error creating output file: %v\n", err)
		os.Exit(2)
	}
	defer output.Close()

	writer := bufio.NewWriter(output)
	defer writer.Flush()

	for _, dir := range dirs {
		filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
			if err != nil || d.IsDir() {
				return nil
			}

			if !isTargetFile(path) {
				return nil
			}

			processFile(path, writer)
			return nil
		})
	}
}

func processFile(path string, writer *bufio.Writer) {
	stop := make(chan bool)
	done := make(chan bool)

	// Spinner-Goroutine
	go func() {
		frames := []string{"⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"}
		i := 0
		for {
			select {
			case <-stop:
				fmt.Fprintf(os.Stderr, "\r✓ %-60s\n", path)
				done <- true
				return
			default:
				fmt.Fprintf(os.Stderr, "\r%s %s", frames[i], path)
				i = (i + 1) % len(frames)
				time.Sleep(100 * time.Millisecond)
			}
		}
	}()

	// Dateiverarbeitung
	content, err := os.ReadFile(path)
	if err != nil {
		fmt.Fprintf(os.Stderr, "\r✗ %s (Lesefehler)\n", path)
		stop <- true
		<-done
		return
	}

	result := fmt.Sprintf("<File Start: %s>\n%s\n<End File: %s>\n\n",
		path,
		strings.TrimSpace(string(content)),
		path,
	)

	if _, err := writer.WriteString(result); err != nil {
		fmt.Fprintf(os.Stderr, "\r✗ %s (Schreibfehler)\n", path)
		stop <- true
		<-done
		return
	}

	stop <- true
	<-done
}

// Unveränderte Hilfsfunktionen
func getDirs(input string) []string {
	if input == "laravel-app" {
		return []string{"./app", "./config", "./routes", "./bootstrap", "./resources", "./database"}
	}
	return []string{input}
}

func validateDirs(dirs []string) {
	for _, dir := range dirs {
		if _, err := os.Stat(dir); os.IsNotExist(err) {
			fmt.Printf("Error: directory %s does not exist\n", dir)
			os.Exit(2)
		}
	}
}

func isTargetFile(path string) bool {
	ext := filepath.Ext(path)
	base := filepath.Base(path)
	return ext == ".php" || ext == ".env" || base == "composer.json"
}
