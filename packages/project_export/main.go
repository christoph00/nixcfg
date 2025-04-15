package main

import (
	"bufio"
	"flag"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
)

const (
	defaultOutput = "prompt.txt"
	version       = "1.0"
)

var (
	wg         sync.WaitGroup
	outputLock sync.Mutex
)

func main() {
	flag.Usage = func() {
		fmt.Printf("Usage: %s [flags] <directory|laravel-app>\n", os.Args[0])
		flag.PrintDefaults()
	}

	outputFile := flag.String("o", defaultOutput, "Output filename")
	workers := flag.Int("w", runtime.NumCPU(), "Number of parallel workers")
	showVersion := flag.Bool("v", false, "Show version")

	flag.Parse()

	if *showVersion {
		fmt.Printf("promptgen v%s\n", version)
		os.Exit(0)
	}

	args := flag.Args()
	if len(args) != 1 {
		flag.Usage()
		os.Exit(1)
	}

	dirs := getDirs(args[0])
	validateDirs(dirs)

	fileChan := make(chan string, 100)
	resultChan := make(chan string, 100)

	// Start writer
	go writeResults(*outputFile, resultChan)

	// Start workers
	for i := 0; i < *workers; i++ {
		wg.Add(1)
		go processFiles(fileChan, resultChan)
	}

	// Collect files
	for _, dir := range dirs {
		collectFiles(dir, fileChan)
	}

	close(fileChan)
	wg.Wait()
	close(resultChan)
}

func getDirs(input string) []string {
	if input == "laravel-app" {
		return []string{
			"./app",
			"./config",
			"./routes",
			"./bootstrap",
		}
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

func collectFiles(dir string, fileChan chan<- string) {
	filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil
		}

		if d.IsDir() {
			return nil
		}

		if isTargetFile(path) {
			fileChan <- path
		}
		return nil
	})
}

func isTargetFile(path string) bool {
	ext := filepath.Ext(path)
	base := filepath.Base(path)

	return ext == ".php" ||
		ext == ".env" ||
		base == "composer.json" ||
		base == "composer.lock"
}

func processFiles(fileChan <-chan string, resultChan chan<- string) {
	defer wg.Done()

	for path := range fileChan {
		content, err := os.ReadFile(path)
		if err != nil {
			continue
		}

		result := fmt.Sprintf("<File Start: %s>\n%s\n<End File: %s>\n",
			path,
			strings.TrimSpace(string(content)),
			path,
		)

		resultChan <- result
	}
}

func writeResults(outputPath string, resultChan <-chan string) {
	file, err := os.Create(outputPath)
	if err != nil {
		fmt.Printf("Error creating output file: %v\n", err)
		os.Exit(3)
	}
	defer file.Close()

	writer := bufio.NewWriter(file)
	defer writer.Flush()

	for result := range resultChan {
		outputLock.Lock()
		_, err := writer.WriteString(result + "\n")
		outputLock.Unlock()

		if err != nil {
			fmt.Printf("Write error: %v\n", err)
			break
		}
	}
}
