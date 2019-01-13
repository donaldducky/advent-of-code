package main

import (
	"bufio"
	"fmt"
	"math"
	"os"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	ps := readParticles("input.txt")

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

func part2() int {
	ps := readParticles("input.txt")

	for i := 0; i < 20000; i++ {
		seen := map[vec3]int{}
		crashes := map[int]bool{}
		for j, p := range ps {
			p.tick()
			ps[j] = p
			if x, ok := seen[p.p]; ok {
				crashes[x] = true
				crashes[j] = true
			} else {
				seen[p.p] = j
			}
		}
		for j, _ := range crashes {
			delete(ps, j)
		}
	}

	return len(ps)
}

type particle struct {
	id int
	p  vec3
	v  vec3
	a  vec3
}

func (p *particle) tick() {
	p.v.x += p.a.x
	p.v.y += p.a.y
	p.v.z += p.a.z
	p.p.x += p.v.x
	p.p.y += p.v.y
	p.p.z += p.v.z
}

type vec3 struct {
	x int
	y int
	z int
}

func readParticles(f string) map[int]particle {
	file, err := os.Open(f)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	ps := map[int]particle{}
	i := 0
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
		ps[i] = p
		i++
	}

	return ps
}
