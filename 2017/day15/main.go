package main

import "fmt"

func main() {
	fmt.Printf("Part 1: %d\n", part1())
}

func part1() int {
	a := 289
	b := 629

	c := 0

	n := 40000000
	for i := 0; i < n; i++ {
		a = next(a, 16807)
		b = next(b, 48271)
		if a%65536 == b%65536 {
			c++
		}
	}

	return c
}

func next(v, f int) int {
	return v * f % 2147483647
}
