package main

import (
	"fmt"
	"strconv"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d", part1())
}

func part1() int {
	input := "hfdlxzhv"

	sum := 0
	for i := 0; i < 128; i++ {
		h := knotHash(fmt.Sprintf("%s-%d", input, i))
		for j := 0; j < len(h)/4; j++ {
			u, err := strconv.ParseUint(h[j*4:j*4+4], 16, 16)
			if err != nil {
				panic(err)
			}
			bits := fmt.Sprintf("%016b\n", u)
			sum += countBits(bits)
		}
	}

	return sum
}

func countBits(b string) int {
	sum := 0
	for _, c := range b {
		if c == '1' {
			sum++
		}
	}

	return sum
}

func knotHash(s string) string {
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
