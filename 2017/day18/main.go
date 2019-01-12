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
	p := process{
		registers: map[string]int{},
	}

	return runProgram(instructions, p)
}

func runProgram(in []string, p process) int {
	sz := len(in)

program:
	for {
		if p.ptr < 0 || p.ptr >= sz {
			break
		}

		v := strings.Split(in[p.ptr], " ")
		j := 1
		switch v[0] {
		case "add":
			p.set(v[1], p.at(v[1])+p.val(v[2]))
		case "jgz":
			if p.val(v[1]) > 0 {
				j = p.val(v[2])
			}
		case "mod":
			p.set(v[1], p.at(v[1])%p.val(v[2]))
		case "mul":
			p.set(v[1], p.at(v[1])*p.val(v[2]))
		case "rcv":
			if p.val(v[1]) != 0 {
				// recover
				break program
			}
		case "set":
			p.set(v[1], p.val(v[2]))
		case "snd":
			p.snd = p.val(v[1])
		}

		p.incPtr(j)
	}

	return p.snd
}

type process struct {
	ptr       int
	registers map[string]int
	snd       int
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
