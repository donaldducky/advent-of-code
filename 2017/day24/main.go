package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
}

func part1() int {
	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	in := strings.Split(strings.TrimSpace(string(bs)), "\n")

	comps := make([]component, len(in))
	for i, line := range in {
		c := component{}
		fmt.Sscanf(line, "%d/%d", &c.a, &c.b)
		comps[i] = c
	}

	compsByPort := map[int][]component{}
	for _, c := range comps {
		compsByPort[c.a] = append(compsByPort[c.a], c)
		if c.a != c.b {
			compsByPort[c.b] = append(compsByPort[c.b], c)
		}
	}

	nextPort := 0

	return maxBridgeStrength(nextPort, compsByPort, 0)
}

type component struct {
	a int
	b int
}

func maxBridgeStrength(port int, available map[int][]component, str int) int {
	if len(available[port]) == 0 {
		return str
	}

	max := 0
	for _, c := range available[port] {
		open := pop(c, available)
		next := c.a
		if c.a == port {
			next = c.b
		}

		str := maxBridgeStrength(next, open, str+c.a+c.b)
		if str > max {
			max = str
		}
	}

	return max
}

func pop(c component, available map[int][]component) map[int][]component {
	new := map[int][]component{}

	for p, components := range available {
		for _, c2 := range components {
			if c == c2 {
				continue
			}

			new[p] = append(new[p], c2)
		}
	}

	return new
}
