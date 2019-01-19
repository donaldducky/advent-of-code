package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	instructions := getInstructions()
	p := process{
		registers: map[string]int{},
	}
	process := runProgram(instructions, p)

	return process.mulCount
}

func part2() int {
	// Figured out the instructions are trying to find out if numbers are
	// composite starting from value in b and ending at value c (inclusive).
	// Found an optimized algorithm for calculating a prime number.
	c := 126300
	cnt := 0
	for b := 109300; b <= c; b += 17 {
		if !isPrime(b) {
			cnt++
		}
	}

	return cnt
}

// I'm no expert in calculating primes, so I used the algorithm here:
// https://stackoverflow.com/a/1801446
func isPrime(n int) bool {
	if n == 2 {
		return true
	}

	if n == 3 {
		return true
	}

	if n%2 == 0 {
		return false
	}

	if n%3 == 0 {
		return false
	}

	i := 5
	w := 2

	for {
		if i*i > n {
			break
		}

		if n%i == 0 {
			return false
		}

		i += w
		w = 6 - w
	}

	return true
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

func runProgram(in []string, p process) process {
	sz := len(in)

	i := 0
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
		i++
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

func (p process) printRegisters(cmd string) {
	registers := []string{"a", "b", "c", "d", "e", "f", "g", "h"}

	rs := []string{}
	for _, r := range registers {
		rs = append(rs, fmt.Sprintf("%s=%d", r, p.val(r)))
	}
	fmt.Printf("ip=%d %s %s\n", p.ptr, cmd, strings.Join(rs, " "))
}
