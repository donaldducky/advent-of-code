package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	g := initGrid()

	g = burst(g, 10000)

	return g.infections
}

func part2() int {
	g := initGrid()

	g = evolvedBurst(g, 10000000)

	return g.infections
}

func initGrid() grid {
	g := grid{
		virus:      vec2{x: 0, y: 0},
		direction:  vec2{x: 0, y: -1},
		infections: 0,
		nodes:      map[vec2]state{},
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
				g.nodes[vec2{x: x - offset, y: y - offset}] = infected
			} else {
				g.nodes[vec2{x: x - offset, y: y - offset}] = clean
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

func evolvedBurst(g grid, n int) grid {
	for i := 0; i < n; i++ {
		switch g.stateAt(g.virus) {
		case clean:
			g.turnLeft()
		case weakened:
		case infected:
			g.turnRight()
		case flagged:
			g.reverse()
		}
		if g.next(g.virus) {
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

type state int

const (
	clean state = iota
	weakened
	infected
	flagged
)

type grid struct {
	virus      vec2
	direction  vec2
	infections int
	nodes      map[vec2]state
}

func (g grid) isInfected(v vec2) bool {
	state, ok := g.nodes[v]
	if ok {
		return state == infected
	}

	return false
}

func (g *grid) toggle(v vec2) bool {
	state, ok := g.nodes[v]
	if ok {
		if state == infected {
			g.nodes[v] = clean
		} else {
			g.nodes[v] = infected
			return true
		}
	} else {
		g.nodes[v] = infected
		return true
	}

	return false
}

func (g grid) stateAt(v vec2) state {
	state, ok := g.nodes[v]
	if !ok {
		state = clean
	}

	return state
}

func (g *grid) next(v vec2) bool {
	state := g.stateAt(v)
	state = (state + 1) % 4

	g.nodes[v] = state

	return state == infected
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

func (g *grid) reverse() {
	g.direction.x = -g.direction.x
	g.direction.y = -g.direction.y
}
