package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %s\n", part1())
}

func part1() string {
	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	in := strings.Split(strings.TrimSpace(string(bs)), ",")

	s := "abcdefghijklmnop"
	for _, l := range in {
		switch l[0] {
		case 's':
			var n int
			fmt.Sscanf(l, "s%d", &n)
			s = spin(s, n)
		case 'x':
			var a, b int
			fmt.Sscanf(l, "x%d/%d", &a, &b)
			s = exchange(s, a, b)
		case 'p':
			var a, b rune
			fmt.Sscanf(l, "p%c/%c", &a, &b)
			s = partner(s, a, b)
		}
	}

	return s
}

func spin(s string, n int) string {
	m := len(s) - n

	return s[m:] + s[0:m]
}

func exchange(s string, a, b int) string {
	r := []rune(s)
	r[a], r[b] = r[b], r[a]

	return string(r)
}

func partner(s string, a, b rune) string {
	var ai, bi int
	for i, r := range s {
		if r == a {
			ai = i
		}
		if r == b {
			bi = i
		}
	}

	return exchange(s, ai, bi)
}
