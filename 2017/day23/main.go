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
	instructions := getInstructions()
	process := runProgram(instructions)

	return process.mulCount
}

type process struct {
	ptr       int
	registers map[string]int
	mulCount  int
}

func getInstructions() []string {
	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	in := strings.Split(strings.TrimSpace(string(bs)), "\n")

	return in
}

func runProgram(in []string) process {
	sz := len(in)
	p := process{
		registers: map[string]int{},
	}

	for {
		if p.ptr < 0 || p.ptr >= sz {
			break
		}

		v := strings.Split(in[p.ptr], " ")
		j := 1
		switch v[0] {
		case "set":
			p.set(v[1], p.val(v[2]))
		case "sub":
			p.set(v[1], p.at(v[1])-p.val(v[2]))
		case "mul":
			p.set(v[1], p.at(v[1])*p.val(v[2]))
			p.mulCount++
		case "jnz":
			if p.val(v[1]) != 0 {
				j = p.val(v[2])
			}
		}

		p.incPtr(j)
	}

	return p
}

func (p *process) at(s string) int {
	if v, ok := p.registers[s]; ok {
		return v
	}

	return 0
}

func (p *process) val(s string) int {
	i, err := strconv.Atoi(s)
	if err == nil {
		return i
	}

	return p.at(s)
}

func (p *process) set(s string, v int) {
	p.registers[s] = v
}

func (p *process) incPtr(v int) {
	p.ptr = p.ptr + v
}
