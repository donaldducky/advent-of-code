package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
}

func part1() int {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	sum := 0
	garbage := false
	skip := false
	nesting := 0

	scanner := bufio.NewReader(file)
	for {
		c, _, err := scanner.ReadRune()
		if err != nil {
			if err == io.EOF {
				break
			} else {
				panic(err)
			}
		}

		if skip {
			skip = false
		} else if garbage {
			switch c {
			case '>':
				garbage = false
			case '!':
				skip = true
			}
		} else {
			switch c {
			case '{':
				nesting++
				sum += nesting
			case '}':
				nesting--
				// assuming entire input is 1 group
				// if nesting == 0 {break 2}
			case '<':
				garbage = true
			}
		}
	}

	return sum
}
