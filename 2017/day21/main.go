package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	book := map[string]grid{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()

		ss := strings.Split(line, " => ")

		in := ss[0]
		out := ss[1]

		book = mapVariations(in, out, book)
	}

	/*
		for in, out := range book {
			fmt.Printf("in: %s out: %s\n", in, out.key())
		}
	*/

	n := 5
	g := keyToGrid(".#./..#/###")
	for i := 0; i < n; i++ {
		g = generate(g, book)
	}

	return g.countOn()
}

func part2() int {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	book := map[string]grid{}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()

		ss := strings.Split(line, " => ")

		in := ss[0]
		out := ss[1]

		book = mapVariations(in, out, book)
	}

	/*
		for in, out := range book {
			fmt.Printf("in: %s out: %s\n", in, out.key())
		}
	*/

	n := 18
	g := keyToGrid(".#./..#/###")
	for i := 0; i < n; i++ {
		g = generate(g, book)
	}

	return g.countOn()
}

func generate(g grid, book map[string]grid) grid {
	sz := g.size

	var d int
	if sz%2 == 0 {
		d = 2
	} else {
		d = 3
	}

	n := sz / d
	c := n * n

	//fmt.Printf("In: d=%d n=%d c=%d\n", d, n, c)
	//g.draw()
	//fmt.Println("")

	sz2 := n * (d + 1)
	points := make(map[int]map[int]bool, sz2)
	for i := 0; i < sz2; i++ {
		points[i] = make(map[int]bool, sz2)
	}

	newGrid := grid{
		size:   sz2,
		points: points,
	}

	for i := 0; i < c; i++ {
		x := i % n
		y := i / n
		//fmt.Printf("i=%d @(%d,%d)\n", i, x, y)
		s := ""

		for j := 0; j < d; j++ {
			for k := 0; k < d; k++ {
				if g.points[x*d+k][y*d+j] {
					s += "#"
				} else {
					s += "."
				}
			}
			if j < d-1 {
				s += "/"
			}
		}

		g2 := keyToGrid(book[s].key())

		ox := x * (d + 1)
		oy := y * (d + 1)
		//fmt.Printf("Offset %d,%d %s → %s\n", ox, oy, s, book[s].key())

		for y2 := 0; y2 < d+1; y2++ {
			for x2 := 0; x2 < d+1; x2++ {
				if g2.points[x2][y2] {
					newGrid.points[ox+x2][oy+y2] = true
				}
			}
		}
	}

	//fmt.Println("Out:")
	//newGrid.draw()
	//fmt.Println("")

	return newGrid
}

func mapVariations(in, out string, book map[string]grid) map[string]grid {
	a := keyToGrid(in)
	b := keyToGrid(out)

	book[a.key()] = b
	for i := 0; i < 3; i++ {
		a = a.rotate()
		book[a.key()] = b
	}
	a = a.flip()
	book[a.key()] = b
	for i := 0; i < 3; i++ {
		a = a.rotate()
		book[a.key()] = b
	}

	return book
}

func keyToGrid(k string) grid {
	rows := strings.Split(k, "/")
	sz := len(rows)

	points := make(map[int]map[int]bool, sz)
	for i := 0; i < sz; i++ {
		points[i] = make(map[int]bool, sz)
	}

	for y, row := range rows {
		for x, r := range row {
			points[x][y] = (r == '#')
		}
	}

	g := grid{
		size:   sz,
		points: points,
	}

	return g
}

type grid struct {
	size   int
	points map[int]map[int]bool
}

func (g grid) key() string {
	s := ""
	for y := 0; y < g.size; y++ {
		for x := 0; x < g.size; x++ {
			if g.points[x][y] {
				s += "#"
			} else {
				s += "."
			}
		}

		if y < g.size-1 {
			s += "/"
		}
	}

	return s
}

func (g grid) rotate() grid {
	sz := g.size

	points := make(map[int]map[int]bool, sz)
	for i := 0; i < sz; i++ {
		points[i] = make(map[int]bool, sz)
	}

	for y := 0; y < sz; y++ {
		for x := 0; x < sz; x++ {
			points[x][y] = g.points[sz-1-y][x]
		}
	}

	g2 := grid{
		size:   sz,
		points: points,
	}

	return g2
}

func (g grid) flip() grid {
	sz := g.size

	points := make(map[int]map[int]bool, sz)
	for i := 0; i < sz; i++ {
		points[i] = make(map[int]bool, sz)
	}

	for y := 0; y < sz; y++ {
		for x := 0; x < sz; x++ {
			points[x][y] = g.points[x][sz-1-y]
		}
	}

	g2 := grid{
		size:   sz,
		points: points,
	}

	return g2
}

func (g grid) draw() {
	sz := g.size

	for y := 0; y < sz; y++ {
		for x := 0; x < sz; x++ {
			if g.points[x][y] {
				fmt.Print("#")
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println("")
	}
}

func (g grid) countOn() int {
	sz := g.size
	sum := 0
	for y := 0; y < sz; y++ {
		for x := 0; x < sz; x++ {
			if g.points[x][y] {
				sum++
			}
		}
	}

	return sum
}
