package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", countValid())
}

func countValid() int {
	file, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	valid := 0
	for scanner.Scan() {
		if lineIsValid(scanner.Text()) {
			valid++
		}
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	return valid
}

func lineIsValid(s string) bool {
	words := strings.Split(s, " ")

	seen := make(map[string]bool)
	for _, w := range words {
		if _, ok := seen[w]; ok {
			return false
		}

		seen[w] = true
	}

	return true
}
