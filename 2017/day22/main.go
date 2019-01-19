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
	g := initGrid()

	g = burst(g, 10000)

	return g.infections
}

func initGrid() grid {
	g := grid{
		virus:      vec2{x: 0, y: 0},
		direction:  vec2{x: 0, y: -1},
		infections: 0,
		nodes:      map[vec2]bool{},
	}

	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	lines := strings.Split(strings.TrimSpace(string(bs)), "\n")

	sz := len(lines)
	offset := sz / 2

	for y, line := range lines {
		for x, r := range line {
			if r == '#' {
				g.nodes[vec2{x: x - offset, y: y - offset}] = true
			} else {
				g.nodes[vec2{x: x - offset, y: y - offset}] = false
			}
		}
	}

	return g
}

func burst(g grid, n int) grid {
	for i := 0; i < n; i++ {
		if g.isInfected(g.virus) {
			g.turnRight()
		} else {
			g.turnLeft()
		}
		if g.toggle(g.virus) {
			g.infections++
		}
		g.virus.x += g.direction.x
		g.virus.y += g.direction.y
	}

	return g
}

type vec2 struct {
	x int
	y int
}

type grid struct {
	virus      vec2
	direction  vec2
	infections int
	nodes      map[vec2]bool
}

func (g grid) isInfected(v vec2) bool {
	infected, ok := g.nodes[v]
	if ok {
		return infected
	}

	return false
}

func (g *grid) toggle(v vec2) bool {
	infected, ok := g.nodes[v]
	if ok {
		g.nodes[v] = !infected
	} else {
		g.nodes[v] = true
	}

	return g.nodes[v]
}

func (g *grid) turnRight() {
	switch g.direction {
	case vec2{x: 1, y: 0}:
		g.direction.x = 0
		g.direction.y = 1
	case vec2{x: -1, y: 0}:
		g.direction.x = 0
		g.direction.y = -1
	case vec2{x: 0, y: 1}:
		g.direction.x = -1
		g.direction.y = 0
	case vec2{x: 0, y: -1}:
		g.direction.x = 1
		g.direction.y = 0
	}
}

func (g *grid) turnLeft() {
	switch g.direction {
	case vec2{x: 1, y: 0}:
		g.direction.x = 0
		g.direction.y = -1
	case vec2{x: -1, y: 0}:
		g.direction.x = 0
		g.direction.y = 1
	case vec2{x: 0, y: 1}:
		g.direction.x = 1
		g.direction.y = 0
	case vec2{x: 0, y: -1}:
		g.direction.x = -1
		g.direction.y = 0
	}
}
