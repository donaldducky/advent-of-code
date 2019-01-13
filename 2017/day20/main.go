package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
}

func part1() int {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	ps := []particle{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		p := particle{}
		fmt.Sscanf(
			scanner.Text(),
			"p=<%d,%d,%d>, v=<%d,%d,%d>, a=<%d,%d,%d>",
			&p.p.x, &p.p.y, &p.p.z,
			&p.v.x, &p.v.y, &p.v.z,
			&p.a.x, &p.a.y, &p.a.z,
		)
		ps = append(ps, p)
	}

	best := -1
	min := math.MaxFloat64
	for i, p := range ps {
		d := math.Abs(float64(p.a.x)) + math.Abs(float64(p.a.y)) + math.Abs(float64(p.a.z))
		if d < min {
			min = d
			best = i
		}
	}

	return best
}

type particle struct {
	id int
	p  vec3
	v  vec3
	a  vec3
}

type vec3 struct {
	x int
	y int
	z int
}
