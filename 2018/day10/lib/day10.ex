defmodule Day10 do
  @moduledoc """
  Documentation for Day10.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Day10.align_stars([
      ...> "position=< 9,  1> velocity=< 0,  2>",
      ...> "position=< 7,  0> velocity=<-1,  0>",
      ...> "position=< 3, -2> velocity=<-1,  1>",
      ...> "position=< 6, 10> velocity=<-2, -1>",
      ...> "position=< 2, -4> velocity=< 2,  2>",
      ...> "position=<-6, 10> velocity=< 2, -2>",
      ...> "position=< 1,  8> velocity=< 1, -1>",
      ...> "position=< 1,  7> velocity=< 1,  0>",
      ...> "position=<-3, 11> velocity=< 1, -2>",
      ...> "position=< 7,  6> velocity=<-1, -1>",
      ...> "position=<-2,  3> velocity=< 1,  0>",
      ...> "position=<-4,  3> velocity=< 2,  0>",
      ...> "position=<10, -3> velocity=<-1,  1>",
      ...> "position=< 5, 11> velocity=< 1, -2>",
      ...> "position=< 4,  7> velocity=< 0, -1>",
      ...> "position=< 8, -2> velocity=< 0,  1>",
      ...> "position=<15,  0> velocity=<-2,  0>",
      ...> "position=< 1,  6> velocity=< 1,  0>",
      ...> "position=< 8,  9> velocity=< 0, -1>",
      ...> "position=< 3,  3> velocity=<-1,  1>",
      ...> "position=< 0,  5> velocity=< 0, -1>",
      ...> "position=<-2,  2> velocity=< 2,  0>",
      ...> "position=< 5, -2> velocity=< 1,  2>",
      ...> "position=< 1,  4> velocity=< 2,  1>",
      ...> "position=<-2,  7> velocity=< 2, -2>",
      ...> "position=< 3,  6> velocity=<-1, -1>",
      ...> "position=< 5,  0> velocity=< 1,  0>",
      ...> "position=<-6,  0> velocity=< 2,  0>",
      ...> "position=< 5,  9> velocity=< 1, -2>",
      ...> "position=<14,  7> velocity=<-2,  0>",
      ...> "position=<-3,  6> velocity=< 2, -1>",
      ...> ])
      3

  """
  def align_stars(lines) do
    stars =
      lines
      |> parse_lines

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({stars, nil}, fn
      _iteration, {stars, nil} ->
        {:cont, {stars, calculate_bounding_box(stars)}}

      iteration, {stars, bounding_box} ->
        new_stars = step(stars)

        new_bounding_box = calculate_bounding_box(new_stars)

        if bounding_box_size(new_bounding_box) > bounding_box_size(bounding_box) do
          draw_letters(stars, bounding_box)
          {:halt, iteration - 1}
        else
          {:cont, {new_stars, new_bounding_box}}
        end
    end)
  end

  def draw_letters(stars, {x_min, x_max, y_min, y_max}) do
    star_map =
      stars
      |> Enum.reduce(MapSet.new(), fn {x, y, _, _}, star_map -> star_map |> MapSet.put({x, y}) end)

    Enum.reduce((y_min - 1)..y_max, fn y, _ ->
      Enum.reduce((x_min - 1)..x_max, fn x, _ ->
        if MapSet.member?(star_map, {x, y}) do
          IO.write("█")
        else
          IO.write(" ")
        end
      end)

      IO.puts("")
    end)
  end

  def step(stars) do
    stars
    |> Enum.map(fn {x, y, vx, vy} -> {x + vx, y + vy, vx, vy} end)
  end

  def calculate_bounding_box(stars) do
    {{x_min, _, _, _}, {x_max, _, _, _}} = stars |> Enum.min_max_by(fn {x, _y, _vx, _vy} -> x end)
    {{_, y_min, _, _}, {_, y_max, _, _}} = stars |> Enum.min_max_by(fn {_x, y, _vx, _vy} -> y end)

    {x_min, x_max, y_min, y_max}
  end

  def bounding_box_size({x_min, x_max, y_min, y_max}) do
    (x_max - x_min) * (y_max - y_min)
  end

  @spec read_input() :: Enumerable.t()
  def read_input() do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
  end

  def parse_lines(input) do
    input
    |> Enum.map(fn line ->
      [x, y, vx, vy] =
        Regex.run(
          ~r/^position=<\s*(\-?\d+),\s+(\-?\d+)> velocity=<\s*(\-?\d+),\s+(\-?\d+)>$/,
          line
        )
        |> Enum.drop(1)
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(&elem(&1, 0))

      {x, y, vx, vy}
    end)
  end
end
