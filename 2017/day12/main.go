package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
}

func part1() int {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	programs := make(map[string][]string)
	for scanner.Scan() {
		line := scanner.Text()
		ss := strings.Split(line, " <-> ")

		id := ss[0]
		linked := strings.Split(ss[1], ", ")
		programs[id] = linked
	}

	return countGroups(programs)
}

func countGroups(pg map[string][]string) int {
	open := []string{"0"}
	closed := make(map[string]bool)

	cnt := 0
	for {
		if len(open) == 0 {
			break
		}

		id := open[0]
		open = append(open[:0], open[1:]...)
		if _, ok := closed[id]; ok {
			continue
		}

		cnt++
		closed[id] = true
		links := pg[id]
		for _, l := range links {
			if _, ok := closed[l]; !ok {
				open = append(open, l)
			}
		}
	}

	return cnt
}
