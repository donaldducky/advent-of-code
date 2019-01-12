package main

import (
	"fmt"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	s := 349
	b := []int{0}
	n := 2017
	c := 0

	for i := 1; i < n+1; i++ {
		c = (c+s)%i + 1

		// insert at position
		// https://github.com/golang/go/wiki/SliceTricks#insert
		// grow slice by 1, shift everything, and set the value
		b = append(b, 0)
		copy(b[c+1:], b[c:])
		b[c] = i
	}

	x := (c + 1) % n

	return b[x]
}

func part2() int {
	s := 349
	n := 50000000
	c := 0

	var r int
	for i := 1; i < n+1; i++ {
		c = (c+s)%i + 1
		if c == 1 {
			r = i
		}
	}

	return r
}
