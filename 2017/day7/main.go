package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

type node struct {
	name     string
	value    int
	parent   string
	children []string
	weight   int
}

func (n node) hasParent() bool {
	return n.parent != ""
}

func (n node) hasChildren() bool {
	return len(n.children) > 0
}

func main() {
	fmt.Printf("Part 1: %s\n", part1())
	fmt.Printf("Part 2: %d\n", part2())
}

func part1() string {
	nodes := readNodes()
	p := findParent(nodes)

	return p.name
}

func part2() int {
	nodes := readNodes()
	p := findParent(nodes)

	nodes = calculateWeights(nodes, p)

	n := nodes[p.name]
	un := findUnbalancedNode(nodes, n)

	return adjustedWeight(nodes, un)
}

func adjustedWeight(nodes map[string]node, n node) int {
	p := nodes[n.parent]

	var w int
	for _, c := range p.children {
		if c != n.name {
			w = nodes[c].weight
			break
		}
	}

	return n.value + (w - n.weight)
}

func findUnbalancedNode(nodes map[string]node, n node) node {
	weightOccurrences := make(map[int][]string, 2)
	for _, c := range n.children {
		w := nodes[c].weight
		weightOccurrences[w] = append(weightOccurrences[w], c)
	}

	for _, ns := range weightOccurrences {
		if len(ns) == 1 {
			return findUnbalancedNode(nodes, nodes[ns[0]])
		}
	}

	return n
}

func calculateWeights(nodes map[string]node, n node) map[string]node {
	if !n.hasChildren() {
		n.weight = n.value
		nodes[n.name] = n

		return nodes
	}

	sum := n.value
	for _, c := range n.children {
		nodes = calculateWeights(nodes, nodes[c])
		sum += nodes[c].weight
	}

	n.weight = sum
	nodes[n.name] = n

	return nodes
}

func readNodes() map[string]node {
	file, err := os.Open("input.txt")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	nodes := make(map[string]node)
	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, " -> ")

		var name string
		var value int
		fmt.Sscanf(parts[0], "%s (%d)", &name, &value)
		node := nodeAt(nodes, name)
		node.name = name
		node.value = value

		if len(parts) == 2 {
			children := strings.Split(parts[1], ", ")
			node.children = children
			for _, c := range children {
				child := nodeAt(nodes, c)
				child.name = c
				child.parent = name
				nodes[c] = child
			}
		}

		nodes[node.name] = node
	}

	return nodes
}

func nodeAt(nodes map[string]node, name string) node {
	if n, ok := nodes[name]; ok {
		return n
	}

	return node{}
}

func findParent(nodes map[string]node) node {
	for _, n := range nodes {
		if !n.hasParent() {
			return n
		}
	}

	panic("could not find parent")
}
