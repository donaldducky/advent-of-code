defmodule Day12Test do
  use ExUnit.Case
  doctest Day12

  import Day12

  test "test name" do
    input = [
      "initial state: #..#.#..##......###...###",
      "",
      "...## => #",
      "..#.. => #",
      ".#... => #",
      ".#.#. => #",
      ".#.## => #",
      ".##.. => #",
      ".#### => #",
      "#.#.# => #",
      "#.### => #",
      "##.#. => #",
      "##.## => #",
      "###.. => #",
      "###.# => #",
      "####. => #"
    ]

    assert sum_pots(input) == 325
  end

  test "step" do
    state = MapSet.new([0, 3, 5, 8, 9, 16, 17, 18, 22, 23, 24])

    rules =
      MapSet.new([
        "...##",
        "..#..",
        ".#...",
        ".#.#.",
        ".#.##",
        ".##..",
        ".####",
        "#.#.#",
        "#.###",
        "##.#.",
        "##.##",
        "###..",
        "###.#",
        "####."
      ])

    s = step(state, rules)
    assert s == MapSet.new([0, 4, 9, 15, 18, 21, 24])
    s = step(s, rules)
    assert s == MapSet.new([0, 1, 4, 5, 9, 10, 15, 18, 21, 24, 25])
    s = step(s, rules)
    assert s == MapSet.new([-1, 1, 5, 8, 10, 15, 18, 21, 25])
    s = step(s, rules)
    assert s == MapSet.new([0, 2, 5, 9, 11, 15, 18, 21, 22, 25, 26])
  end
end
