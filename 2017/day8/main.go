package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
}

func part1() int {
	lines := readInput()

	var r1, in, r2, cmp string
	var v1, v2 int
	registers := make(map[string]int)
	for _, line := range lines {
		fmt.Sscanf(line, "%s %s %d if %s %s %d", &r1, &in, &v1, &r2, &cmp, &v2)

		registers, vr1 := valueAt(registers, r1)
		registers, vr2 := valueAt(registers, r2)

		if holds(vr2, cmp, v2) {
			registers[r1] = modify(vr1, in, v1)
		}
	}

	max := math.MinInt64
	for _, v := range registers {
		if v > max {
			max = v
		}
	}

	return max
}

func readInput() []string {
	contents, err := ioutil.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	s := string(contents)
	s = strings.TrimSpace(s)

	return strings.Split(s, "\n")
}

func valueAt(registers map[string]int, r string) (map[string]int, int) {
	if v, ok := registers[r]; ok {
		return registers, v
	}

	v := 0
	registers[r] = v

	return registers, v
}

func holds(vr int, cmp string, v int) bool {
	switch cmp {
	case "!=":
		return vr != v
	case "<":
		return vr < v
	case "<=":
		return vr <= v
	case "==":
		return vr == v
	case ">":
		return vr > v
	case ">=":
		return vr >= v
	default:
		panic(fmt.Sprintf("Unknown comparison operator: %s", cmp))
	}
}

func modify(vr int, in string, v int) int {
	switch in {
	case "inc":
		return vr + v
	case "dec":
		return vr - v
	default:
		panic(fmt.Sprintf("Unknown instruction: %s", in))
	}
}
