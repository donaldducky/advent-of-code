package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
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

	instructions := strings.Split(strings.TrimSpace(string(bs)), "\n")
	sz := len(instructions)

	reg := map[string]int{}
	ptr := 0
	snd := 0
	for {
		if ptr < 0 || ptr >= sz {
			break
		}

		p := strings.Split(instructions[ptr], " ")
		switch p[0] {
		case "add":
			x, y := p[1], p[2]
			reg[x] = valAtReg(reg, x) + val(reg, y)
		case "jgz":
			x, y := p[1], p[2]
			if val(reg, x) > 0 {
				ptr += val(reg, y)
			} else {
				ptr++
			}
		case "mod":
			x, y := p[1], p[2]
			reg[x] = valAtReg(reg, x) % val(reg, y)
		case "mul":
			x, y := p[1], p[2]
			reg[x] = valAtReg(reg, x) * val(reg, y)
		case "rcv":
			x := p[1]
			if val(reg, x) != 0 {
				// recover
				return snd
			}
		case "set":
			x, y := p[1], p[2]
			reg[x] = val(reg, y)
		case "snd":
			x := p[1]
			snd = val(reg, x)
		}

		if p[0] != "jgz" {
			ptr++
		}
	}

	return 0
}

func valAtReg(reg map[string]int, s string) int {
	if v, ok := reg[s]; ok {
		return v
	}

	return 0
}

func val(reg map[string]int, p string) int {
	i, err := strconv.Atoi(p)
	if err == nil {
		return i
	}

	return valAtReg(reg, p)
}
