package main

import (
	"fmt"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
}

func part1() int {
	chk := 12629077
	fns := map[state]stateFunction{

		A: func(m *machine) {
			if !m.cur() {
				m.set(true)
				m.right()
				m.setState(B)
			} else {
				m.set(false)
				m.left()
				m.setState(B)
			}
		},

		B: func(m *machine) {
			if !m.cur() {
				m.right()
				m.setState(C)
			} else {
				m.left()
				m.setState(B)
			}
		},

		C: func(m *machine) {
			if !m.cur() {
				m.set(true)
				m.right()
				m.setState(D)
			} else {
				m.set(false)
				m.left()
				m.setState(A)
			}
		},

		D: func(m *machine) {
			if !m.cur() {
				m.set(true)
				m.left()
				m.setState(E)
			} else {
				m.left()
				m.setState(F)
			}
		},

		E: func(m *machine) {
			if !m.cur() {
				m.set(true)
				m.left()
				m.setState(A)
			} else {
				m.set(false)
				m.left()
				m.setState(D)
			}
		},

		F: func(m *machine) {
			if !m.cur() {
				m.set(true)
				m.right()
				m.setState(A)
			} else {
				m.left()
				m.setState(E)
			}
		},
	}

	m := machine{
		blueprint: fns,
		tape:      map[int]bool{},
	}

	for i := 0; i < chk; i++ {
		m.play()
	}

	return m.on
}

type state int
type stateFunction func(m *machine)

const (
	A state = iota
	B
	C
	D
	E
	F
)

type machine struct {
	blueprint map[state]stateFunction
	on        int
	ptr       int
	state     state
	tape      map[int]bool
}

func (m *machine) play() {
	m.blueprint[m.state](m)
}

func (m *machine) cur() bool {
	if b, ok := m.tape[m.ptr]; ok {
		return b
	}

	return false
}

func (m *machine) set(b bool) {
	m.tape[m.ptr] = b
	if b {
		m.on++
	} else {
		m.on--
	}
}

func (m *machine) right() {
	m.ptr++
}

func (m *machine) left() {
	m.ptr--
}

func (m *machine) setState(s state) {
	m.state = s
}
