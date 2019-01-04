package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"sort"
	"strings"
)

type isValid func(string) bool

func main() {
	fmt.Printf("Part 1: %d\n", countValid(isLineValid))
	fmt.Printf("Part 2: %d\n", countValid(isLineValidAnagram))
}

func countValid(fn isValid) int {
	file, err := os.Open("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	valid := 0
	for scanner.Scan() {
		if fn(scanner.Text()) {
			valid++
		}
	}

	if err := scanner.Err(); err != nil {
		log.Fatal(err)
	}

	return valid
}

func isLineValid(s string) bool {
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

func isLineValidAnagram(s string) bool {
	words := strings.Split(s, " ")

	seen := make(map[string]bool)
	for _, w := range words {
		ks := strings.Split(w, "")
		sort.Strings(ks)
		k := strings.Join(ks, "")

		if _, ok := seen[k]; ok {
			return false
		}

		seen[k] = true
	}

	return true
}
