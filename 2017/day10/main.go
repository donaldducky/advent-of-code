package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %s\n", part2())
}

func part1() int {
	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}
	in := strings.Split(strings.TrimSpace(string(bs)), ",")

	sz := 256
	list := make([]int, sz)

	pos := 0
	skip := 0
	for i := 0; i < sz; i++ {
		list[i] = i
	}

	for _, s := range in {
		n, err := strconv.Atoi(s)
		if err != nil {
			panic(err)
		}

		list = reverseCircular(list, pos, n, sz)
		pos += n + skip
		skip++
	}

	return list[0] * list[1]
}

func part2() string {
	bs, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}
	s := strings.TrimSpace(string(bs))
	in := append([]byte(s), []byte{17, 31, 73, 47, 23}...)

	sz := 256
	list := make([]int, sz)

	pos := 0
	skip := 0
	for i := 0; i < sz; i++ {
		list[i] = i
	}

	for i := 0; i < 64; i++ {
		for _, b := range in {
			n := int(b)

			list = reverseCircular(list, pos, n, sz)
			pos += n + skip
			skip++
		}
	}

	dense := make([]int, 16)
	for i := 0; i < 16; i++ {
		a := i * 16
		b := a + 16
		dense[i] = list[a]
		for j := a + 1; j < b; j++ {
			dense[i] ^= list[j]
		}
	}

	hex := make([]string, 16)
	for i, n := range dense {
		hex[i] = fmt.Sprintf("%02x", n)
	}

	return strings.Join(hex, "")
}

func reverseCircular(ls []int, pos, n, sz int) []int {
	for i := 0; i < n/2; i++ {
		k := (pos + i) % sz
		k2 := (pos + (n - i) - 1) % sz
		ls[k], ls[k2] = ls[k2], ls[k]
	}

	return ls
}
