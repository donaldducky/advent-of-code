defmodule Day18 do
  @moduledoc """
  Documentation for Day18.

  . = open ground
  | = trees
  # = lumberyard

  open -> trees, if 3 or more adjacent are trees
  trees -> lumberyard, if 3 or more adjacent are lumber
  lumberyard -> lumberyard, if adjacent to > 1 lumberyard and > 1 trees
  lumberyard -> open, if not adjacent to > 1 lumberyard and > 1 trees
  """

  @doc """
  iex> Day18.parse_map([
  ...> ".#.#",
  ...> "....",
  ...> ".|..",
  ...> "..|#",
  ...> ])
  {
    %{
      {0, 0} => {".", 0, 1},
      {1, 0} => {"#", 0, 0},
      {2, 0} => {".", 0, 2},
      {3, 0} => {"#", 0, 0},
      {0, 1} => {".", 1, 1},
      {1, 1} => {".", 1, 1},
      {2, 1} => {".", 1, 2},
      {3, 1} => {".", 0, 1},
      {0, 2} => {".", 1, 0},
      {1, 2} => {"|", 1, 0},
      {2, 2} => {".", 2, 1},
      {3, 2} => {".", 1, 1},
      {0, 3} => {".", 1, 0},
      {1, 3} => {".", 2, 0},
      {2, 3} => {"|", 1, 1},
      {3, 3} => {"#", 1, 0},
    },
    4,
    4,
  }
  """
  def parse_map([first | _] = lines) do
    width = String.length(first)
    height = Enum.count(lines)

    map =
      lines
      |> Stream.map(&String.codepoints/1)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, map ->
        line
        |> Enum.with_index()
        |> Enum.reduce(map, fn {cp, x}, map ->
          {n_trees, n_lumberyards} =
            case cp do
              "|" ->
                {1, 0}

              "#" ->
                {0, 1}

              "." ->
                {0, 0}
            end

          update_grid(map, {x, y}, cp, {n_trees, n_lumberyards}, width, height)
        end)
      end)

    {map, width, height}
  end

  defp update_grid(map, {x, y}, cp, {n_trees, n_lumberyards}, width, height) do
    Enum.reduce((y - 1)..(y + 1), map, fn y_offset, map ->
      Enum.reduce((x - 1)..(x + 1), map, fn x_offset, map ->
        case {x_offset, y_offset} do
          {^x, ^y} ->
            Map.update(map, {x, y}, {cp, 0, 0}, fn {_, trees, lumbers} ->
              {cp, trees, lumbers}
            end)

          {xa, ya} when xa >= 0 and xa < width and ya >= 0 and ya < height ->
            Map.update(map, {xa, ya}, {nil, n_trees, n_lumberyards}, fn {char, trees, lumbers} ->
              {char, trees + n_trees, lumbers + n_lumberyards}
            end)

          _ ->
            map
        end
      end)
    end)
  end

  @doc """
  iex> Day18.simulate_minutes(Day18.parse_map([
  ...>   ".#.#...|#.",
  ...>   ".....#|##|",
  ...>   ".|..|...#.",
  ...>   "..|#.....#",
  ...>   "#.#|||#|#|",
  ...>   "...#.||...",
  ...>   ".|....|...",
  ...>   "||...#|.#|",
  ...>   "|.||||..|.",
  ...>   "...#.|..|.",
  ...> ]), 1)
  Day18.parse_map([
    ".......##.",
    "......|###",
    ".|..|...#.",
    "..|#||...#",
    "..##||.|#|",
    "...#||||..",
    "||...|||..",
    "|||||.||.|",
    "||||||||||",
    "....||..|.",
  ])

  iex> Day18.simulate_minutes(Day18.parse_map([
  ...>   ".#.#...|#.",
  ...>   ".....#|##|",
  ...>   ".|..|...#.",
  ...>   "..|#.....#",
  ...>   "#.#|||#|#|",
  ...>   "...#.||...",
  ...>   ".|....|...",
  ...>   "||...#|.#|",
  ...>   "|.||||..|.",
  ...>   "...#.|..|.",
  ...> ]), 10)
  Day18.parse_map([
    ".||##.....",
    "||###.....",
    "||##......",
    "|##.....##",
    "|##.....##",
    "|##....##|",
    "||##.####|",
    "||#####|||",
    "||||#|||||",
    "||||||||||",
  ])
  """
  def simulate_minutes({map, width, height}, number_of_minutes) do
    map =
      1..number_of_minutes
      |> Enum.reduce(map, fn _i, map ->
        map
        |> Enum.reduce(%{}, fn {{x, y}, {cp, num_trees, num_lumberyards}}, next_map ->
          tile = next_tile(cp, num_trees, num_lumberyards)

          {n_trees, n_lumberyards} =
            case tile do
              "|" ->
                {1, 0}

              "#" ->
                {0, 1}

              "." ->
                {0, 0}
            end

          update_grid(next_map, {x, y}, tile, {n_trees, n_lumberyards}, width, height)
        end)
      end)

    {map, width, height}
  end

  defp next_tile(codepoint, num_trees, _num_lumberyards) when codepoint == "." and num_trees > 2,
    do: "|"

  defp next_tile(codepoint, _num_trees, num_lumberyards)
       when codepoint == "|" and num_lumberyards > 2,
       do: "#"

  defp next_tile(codepoint, num_trees, num_lumberyards)
       when codepoint == "#" and (num_trees < 1 or num_lumberyards < 1),
       do: "."

  defp next_tile(codepoint, _, _), do: codepoint

  @doc """
  iex> Day18.calculate_resource_value(Day18.parse_map([
  ...>  ".||##.....",
  ...>  "||###.....",
  ...>  "||##......",
  ...>  "|##.....##",
  ...>  "|##.....##",
  ...>  "|##....##|",
  ...>  "||##.####|",
  ...>  "||#####|||",
  ...>  "||||#|||||",
  ...>  "||||||||||",
  ...>]))
  1147
  """
  def calculate_resource_value({map, _width, _height}) do
    {tree_count, lumberyard_count} =
      map
      |> Enum.reduce({0, 0}, fn {_, {cp, _, _}}, {tree_count, lumberyard_count} ->
        case cp do
          "|" -> {tree_count + 1, lumberyard_count}
          "#" -> {tree_count, lumberyard_count + 1}
          _ -> {tree_count, lumberyard_count}
        end
      end)

    tree_count * lumberyard_count
  end

  @doc """
  """
  def first_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_map()
    |> simulate_minutes(10)
    |> calculate_resource_value()
  end
end
