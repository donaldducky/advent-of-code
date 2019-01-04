package main

import "testing"

var stepsFromTests = []struct {
	in  int
	out int
}{
	{1, 0},

	{2, 1},
	{3, 2},
	{4, 1},
	{5, 2},
	{6, 1},
	{7, 2},
	{8, 1},
	{9, 2},

	{10, 3},
	{11, 2},
	{12, 3},
	{13, 4},
	{14, 3},
	{15, 2},
	{24, 3},
	{25, 4},

	{26, 5},
	{28, 3},
	{49, 6},
}

func TestStepsFrom(t *testing.T) {
	for _, tt := range stepsFromTests {
		t.Run("", func(t *testing.T) {
			s := stepsFrom(tt.in)
			if s != tt.out {
				t.Fatalf("stepsFrom(%d) != %d, got: %d", tt.in, tt.out, s)
			}
		})
	}
}
