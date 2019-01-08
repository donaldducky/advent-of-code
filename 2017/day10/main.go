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

func reverseCircular(ls []int, pos, n, sz int) []int {
	for i := 0; i < n/2; i++ {
		k := (pos + i) % sz
		k2 := (pos + (n - i) - 1) % sz
		ls[k], ls[k2] = ls[k2], ls[k]
	}

	return ls
}
