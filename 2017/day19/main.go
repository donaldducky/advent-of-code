package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %s\n", part1())
}

func part1() string {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	y := 0
	tubes := map[int]map[int]rune{}
	for scanner.Scan() {
		line := strings.TrimRight(scanner.Text(), " \n")

		tubes[y] = map[int]rune{}
		for x, r := range line {
			if r != ' ' {
				tubes[y][x] = r
			}
		}

		y++
	}

	sy := 0
	var sx int
	for x, r := range tubes[sy] {
		if r == '|' {
			sx = x
			break
		}
	}

	letters := []rune{}
	x, y := sx, sy
	dx, dy := 0, 1
	for {
		x += dx
		y += dy

		r, ok := tubes[y][x]
		if !ok {
			break
		}

		switch r {
		case '|':
			// continue along
		case '-':
			// continue along
		case '+':
			dx, dy = changeDirection(x, y, dx, dy, tubes)
		default:
			// assume it's a letter
			letters = append(letters, r)
		}
	}

	return string(letters)
}

func changeDirection(x, y, dx, dy int, tubes map[int]map[int]rune) (int, int) {
	neighbours := [][]int{
		[]int{1, 0},
		[]int{-1, 0},
		[]int{0, 1},
		[]int{0, -1},
	}

	for _, p := range neighbours {
		if p[0] == dx || p[1] == dy {
			continue
		}

		x2 := x + p[0]
		y2 := y + p[1]
		_, ok := tubes[y2][x2]
		if !ok {
			continue
		}

		return p[0], p[1]
	}

	panic(fmt.Sprintf("Could not find new direction @(%d, %d) going %d,%d", x, y, dx, dy))
}
