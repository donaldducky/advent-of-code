package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
	"time"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
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

func part2() int {
	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	instructions := strings.Split(strings.TrimSpace(string(bs)), "\n")
	//	instructions = []string{
	//		"snd 1",
	//		"snd 2",
	//		"snd p",
	//		"rcv a",
	//		"rcv b",
	//		"rcv c",
	//		"rcv d",
	//	}

	p0 := process{
		id: 0,
		registers: map[string]int{
			"p": 0,
		},
		outCh: make(chan int),
		inCh:  make(chan int, 100000),
	}

	p1 := process{
		id: 1,
		registers: map[string]int{
			"p": 1,
		},
		outCh: make(chan int),
		inCh:  make(chan int, 100000),
	}

	go runProgram2(instructions, &p0)
	go runProgram2(instructions, &p1)

loop:
	for {
		select {
		case msg := <-p0.outCh:
			//fmt.Printf("Received message from p0: %d\n", msg)
			p1.inCh <- msg
		case msg := <-p1.outCh:
			//fmt.Printf("Received message from p1: %d\n", msg)
			p0.inCh <- msg
		case <-time.After(1 * time.Second):
			break loop
		}
	}

	return p1.sendCount
}

func runProgram2(in []string, p *process) {
	sz := len(in)

	for {
		if p.ptr < 0 || p.ptr >= sz {
			break
		}

		v := strings.Split(in[p.ptr], " ")
		j := 1
		switch v[0] {
		case "rcv":
			//fmt.Printf("%d: waiting to receive\n", p.id)
			val := <-p.inCh
			p.set(v[1], val)
			//fmt.Printf("%d: received: %d\n", p.id, val)
		case "snd":
			p.sendCount++
			p.outCh <- p.val(v[1])
		case "set":
			p.set(v[1], p.val(v[2]))
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
		}

		p.incPtr(j)
	}

	fmt.Println("terminating")
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
	id        int
	ptr       int
	registers map[string]int
	snd       int
	outCh     chan int
	inCh      chan int
	sendCount int
}

type message struct {
	fromId int
	value  int
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
