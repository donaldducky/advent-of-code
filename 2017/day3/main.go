package main

import (
	"fmt"
	"math"
)

func main() {
	in := 277678

	fmt.Printf("part 1: %d\n", stepsFrom(in))
}

func stepsFrom(n int) int {
	visited := make(map[string]bool)

	vx := 0
	vy := 1
	x := 0
	y := 0
	k := key(x, y)
	visited[k] = true
	for i := 1; i < n; i++ {
		vx2, vy2 := turnLeft(vx, vy)
		x2 := x + vx2
		y2 := y + vy2

		k = key(x2, y2)
		if _, ok := visited[k]; ok {
			x2 = x + vx
			y2 = y + vy
			k = key(x2, y2)
		} else {
			vx = vx2
			vy = vy2
		}

		visited[k] = true

		x = x2
		y = y2
	}

	return manhattanDistance(x, y, 0, 0)
}

func turnLeft(x, y int) (int, int) {
	if x == 1 && y == 0 {
		return 0, -1
	} else if x == 0 && y == -1 {
		return -1, 0
	} else if x == -1 && y == 0 {
		return 0, 1
	} else if x == 0 && y == 1 {
		return 1, 0
	}

	panic(fmt.Sprintf("Got bad direction x=%d, y=%d", x, y))
}

func key(x, y int) string {
	return fmt.Sprintf("%d,%d", x, y)
}

func manhattanDistance(x, y, x2, y2 int) int {
	return int(math.Abs(float64(x2-x)) + math.Abs(float64(y2-y)))
}
