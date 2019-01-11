package main

import (
	"fmt"
	"strconv"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
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

func part2() int {
	input := "hfdlxzhv"

	grid := map[int]map[int]rune{}
	for i := 0; i < 128; i++ {
		grid[i] = map[int]rune{}
		h := knotHash(fmt.Sprintf("%s-%d", input, i))
		for j := 0; j < len(h)/4; j++ {
			u, err := strconv.ParseUint(h[j*4:j*4+4], 16, 16)
			if err != nil {
				panic(err)
			}
			bits := fmt.Sprintf("%016b\n", u)
			for k, bit := range bits {
				y := j*16 + k
				grid[i][y] = bit
			}
		}
	}

	return countRegions(grid)
}

func countRegions(g map[int]map[int]rune) int {
	sum := 0

	seen := map[int]map[int]int{}
	for i := 0; i < 128; i++ {
		seen[i] = map[int]int{}
	}

	for i := 0; i < 128; i++ {
		for j := 0; j < 128; j++ {
			if g[i][j] == '1' {
				if _, ok := seen[i][j]; !ok {
					sum++
					seen = markRegion(g, sum, i, j, seen)
				}
			}
		}
	}

	return sum
}

type vec2 struct {
	x int
	y int
}

func markRegion(g map[int]map[int]rune, id, x, y int, seen map[int]map[int]int) map[int]map[int]int {
	open := []vec2{vec2{x: x, y: y}}

	for {
		if len(open) == 0 {
			break
		}

		v := open[0]
		open = append(open[:0], open[1:]...)
		if g[v.x][v.y] == '0' {
			continue
		}
		if _, ok := seen[v.x][v.y]; ok {
			continue
		}

		seen[v.x][v.y] = id
		ns := neighbours(v)
		for _, n := range ns {
			if g[n.x][n.y] == '1' {
				open = append(open, n)
			}
		}
	}

	return seen
}

func neighbours(v vec2) []vec2 {
	return []vec2{
		vec2{v.x + 1, v.y},
		vec2{v.x - 1, v.y},
		vec2{v.x, v.y + 1},
		vec2{v.x, v.y - 1},
	}
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
