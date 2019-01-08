package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strings"
)

type vector3 struct {
	x int
	y int
	z int
}

func (v vector3) add(dv vector3) vector3 {
	return vector3{x: v.x + dv.x, y: v.y + dv.y, z: v.z + dv.z}
}

func (v vector3) distance(v2 vector3) int {
	return int(math.Abs(float64(v.x-v2.x))+math.Abs(float64(v.y-v2.y))+math.Abs(float64(v.z-v2.z))) / 2
}

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	in := strings.Split(strings.TrimSpace(string(bs)), ",")

	v := vector3{}
	for _, d := range in {
		v = v.add(direction(d))
	}

	o := vector3{}

	return o.distance(v)
}

func part2() int {
	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	in := strings.Split(strings.TrimSpace(string(bs)), ",")

	o := vector3{}
	v := vector3{}
	max := math.MinInt64
	for _, d := range in {
		v = v.add(direction(d))
		dist := o.distance(v)
		if dist > max {
			max = dist
		}
	}

	return max
}

func direction(d string) vector3 {
	switch d {
	case "ne":
		return vector3{x: 1, y: 0, z: -1}
	case "n":
		return vector3{x: 0, y: 1, z: -1}
	case "nw":
		return vector3{x: -1, y: 1, z: 0}
	case "se":
		return vector3{x: 1, y: -1, z: 0}
	case "s":
		return vector3{x: 0, y: -1, z: 1}
	case "sw":
		return vector3{x: -1, y: 0, z: 1}
	default:
		panic(fmt.Sprintf("unknown direction %s", d))
	}
}
