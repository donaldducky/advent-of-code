package main

import (
	"fmt"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
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
