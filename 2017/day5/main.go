package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"strconv"
	"strings"
)

func main() {
	fmt.Printf("part 1: %d\n", part1())
}

func part1() int {
	lines := readInput()
	jumps := mapStringsToInt(lines)

	i := 0
	ptr := 0
	max := len(jumps) - 1

	for {
		if ptr < 0 || ptr > max {
			break
		}

		jump := jumps[ptr]
		jumps[ptr] += 1
		ptr += jump

		i++
	}

	return i
}

func readInput() []string {
	contents, err := ioutil.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	s := string(contents)
	s = strings.TrimSpace(s)

	return strings.Split(s, "\n")
}

func mapStringsToInt(xs []string) []int {
	ints := make([]int, len(xs))
	for i, s := range xs {
		in, err := strconv.Atoi(s)
		if err != nil {
			log.Fatal(err)
		}

		ints[i] = in
	}

	return ints
}
