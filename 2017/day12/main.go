package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	programs := readPrograms()

	seen := make(map[string]bool)
	cnt, seen := countProgramsInGroup(programs, "0", seen)

	return cnt
}

func part2() int {
	programs := readPrograms()

	cnt := 0
	seen := make(map[string]bool)
	for id, _ := range programs {
		if _, ok := seen[id]; !ok {
			cnt++
			_, seen = countProgramsInGroup(programs, id, seen)
		}
	}

	return cnt
}

func readPrograms() map[string][]string {
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

	return programs
}

func countProgramsInGroup(pg map[string][]string, s string, seen map[string]bool) (int, map[string]bool) {
	open := []string{s}

	cnt := 0
	for {
		if len(open) == 0 {
			break
		}

		id := open[0]
		open = append(open[:0], open[1:]...)
		if _, ok := seen[id]; ok {
			continue
		}

		cnt++
		seen[id] = true
		links := pg[id]
		for _, l := range links {
			if _, ok := seen[l]; !ok {
				open = append(open, l)
			}
		}
	}

	return cnt, seen
}
