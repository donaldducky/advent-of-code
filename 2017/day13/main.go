package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	f, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	s := bufio.NewScanner(f)
	layers := map[int]int{}
	for s.Scan() {
		var l, r int
		_, err := fmt.Sscanf(s.Text(), "%d: %d", &l, &r)
		if err != nil {
			panic(err)
		}

		layers[l] = r
	}

	if err := s.Err(); err != nil {
		panic(err)
	}

	severity := 0
	for l, r := range layers {
		n := 2 * (r - 1)
		rem := l % n
		pos := rem
		if rem > r-1 {
			pos = n - pos
		}
		if pos == 0 {
			severity += l * r
		}
	}

	return severity
}

func part2() int {
	f, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer f.Close()

	s := bufio.NewScanner(f)
	layers := map[int]int{}
	for s.Scan() {
		var l, r int
		_, err := fmt.Sscanf(s.Text(), "%d: %d", &l, &r)
		if err != nil {
			panic(err)
		}

		layers[l] = r
	}

	if err := s.Err(); err != nil {
		panic(err)
	}

	delay := 0

	caught := false
	for {
		for l, r := range layers {
			n := 2 * (r - 1)
			rem := (l + delay) % n
			pos := rem
			if rem > r-1 {
				pos = n - pos
			}
			if pos == 0 {
				caught = true
				delay++
				break
			}
		}

		if !caught {
			break
		}
		caught = false
	}

	return delay
}
