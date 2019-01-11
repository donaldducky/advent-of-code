package main

import "fmt"

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
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

func part2() int {
	a := 289
	b := 629

	c := 0

	//n := 40000000
	n := 5000000
	for i := 0; i < n; i++ {
		a = next2(a, 16807, 4)
		b = next2(b, 48271, 8)
		if a%65536 == b%65536 {
			c++
		}
	}

	return c
}

func next(v, f int) int {
	return v * f % 2147483647
}

func next2(v, f, m int) int {
	for {
		v = next(v, f)
		if v%m == 0 {
			break
		}
	}

	return v
}
