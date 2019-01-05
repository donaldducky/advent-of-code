package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"strconv"
	"strings"
)

func main() {
	fmt.Printf("Part 1: %d\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() int {
	lines := readInput()

	if len(lines) > 1 {
		log.Fatal("Expected one line")
	}

	banks := mapStringsToInts(strings.Split(lines[0], "\t"))

	seen := make(map[string]bool)

	i := 0
	for {
		k := key(banks)
		if _, ok := seen[k]; ok {
			break
		}

		seen[k] = true
		banks = balance(banks)
		i++
	}

	return i
}

func part2() int {
	lines := readInput()

	if len(lines) > 1 {
		log.Fatal("Expected one line")
	}

	banks := mapStringsToInts(strings.Split(lines[0], "\t"))

	seen := make(map[string]int)

	i := 0
	for {
		k := key(banks)
		if v, ok := seen[k]; ok {
			return i - v
		}

		seen[k] = i
		banks = balance(banks)
		i++
	}
}

func readInput() []string {
	contents, err := ioutil.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}

	s := string(contents)
	s = strings.TrimSpace(s)

	return strings.Split(s, "\n")
}

func mapStringsToInts(xs []string) []int {
	ns := make([]int, len(xs))

	for i, s := range xs {
		n, err := strconv.Atoi(s)
		if err != nil {
			log.Fatal(err)
		}
		ns[i] = n
	}

	return ns
}

func key(ns []int) string {
	xs := make([]string, len(ns))

	s := 0
	for i, n := range ns {
		xs[i] = strconv.Itoa(n)
		s += n
	}

	return strings.Join(xs, ",")
}

func biggestBank(ns []int) (int, int) {
	max := math.MinInt64
	maxIndex := 0
	for i, n := range ns {
		if n > max {
			maxIndex = i
			max = n
		}
	}

	return maxIndex, max
}

func balance(ns []int) []int {
	idx, biggestBank := biggestBank(ns)

	ns[idx] = 0
	n := len(ns)
	div := int(biggestBank / n)
	rem := biggestBank % n

	for i, _ := range ns {
		ns[i] += div
	}

	i := idx + 1
	for r := rem; r > 0; r-- {
		ns[i%n]++
		i++
	}

	return ns
}
