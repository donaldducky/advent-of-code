defmodule Day23 do
  @moduledoc """
  Documentation for Day23.
  """

  @doc """
  iex> Day23.parse_input([
  ...>   "pos=<0,0,0>, r=4",
  ...>   "pos=<1,0,0>, r=1",
  ...>   "pos=<4,0,0>, r=3",
  ...>   "pos=<0,2,0>, r=1",
  ...>   "pos=<0,5,0>, r=3",
  ...>   "pos=<0,0,3>, r=1",
  ...>   "pos=<1,1,1>, r=1",
  ...>   "pos=<1,1,2>, r=1",
  ...>   "pos=<1,3,1>, r=1",
  ...> ])
  %{
    {0, 0, 0} => 4,
    {1, 0, 0} => 1,
    {4, 0, 0} => 3,
    {0, 2, 0} => 1,
    {0, 5, 0} => 3,
    {0, 0, 3} => 1,
    {1, 1, 1} => 1,
    {1, 1, 2} => 1,
    {1, 3, 1} => 1,
  }
  """
  def parse_input(lines) do
    lines
    |> Enum.map(fn line ->
      Regex.run(
        ~r/^pos=<(\-?\d+),(\-?\d+),(\-?\d+)>, r=(\d+)$/,
        line
      )
      |> Enum.drop(1)
      |> Stream.map(&Integer.parse/1)
      |> Enum.map(&elem(&1, 0))
    end)
    |> Stream.map(fn [x, y, z, r] -> {{x, y, z}, r} end)
    |> Enum.into(%{})
  end

  @doc """
  iex> Day23.max_power(%{
  ...>   {0, 0, 0} => 4,
  ...>   {0, 5, 0} => -7,
  ...>   {4, 0, 0} => 3,
  ...>   {0, 2, 0} => -1,
  ...> })
  {{0, 0, 0}, 4}
  """
  def max_power(nanobots) do
    nanobots
    |> Enum.max_by(fn {_, r} -> r end)
  end

  @doc """
  iex> Day23.in_range({0, 0, 0}, {0, 0, 0}, 4)
  true

  iex> Day23.in_range({0, 0, 0}, {0, 5, 0}, 4)
  false
  """
  def in_range(pos1, pos2, r) do
    manhattan_distance(pos1, pos2) <= r
  end

  @doc """
  iex> Day23.count_nanobots_in_range(%{
  ...>  {0, 0, 0} => 4,
  ...>  {1, 0, 0} => 1,
  ...>  {4, 0, 0} => 3,
  ...>  {0, 2, 0} => 1,
  ...>  {0, 5, 0} => 3,
  ...>  {0, 0, 3} => 1,
  ...>  {1, 1, 1} => 1,
  ...>  {1, 1, 2} => 1,
  ...>  {1, 3, 1} => 1,
  ...> })
  7
  """
  def count_nanobots_in_range(nanobots) do
    {max_pos, r} = max_power(nanobots)

    nanobots
    |> Enum.count(fn {pos, _} ->
      in_range(pos, max_pos, r)
    end)
  end

  def first_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_input()
    |> count_nanobots_in_range()
  end

  def second_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_input()
    |> closest_distance_to_most_nanobots()
  end

  @doc """
  iex> Day23.manhattan_distance({1, 1, 1}, {0, 0, 0})
  3

  iex> Day23.manhattan_distance({1, -6, 1}, {6, -6, 10})
  14
  """
  def manhattan_distance({x1, y1, z1}, {x2, y2, z2}) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2)
  end

  @doc """
  iex> Day23.closest_distance_to_most_nanobots(%{
  ...>   {10, 12, 12} => 2,
  ...>   {12, 14, 12} => 2,
  ...>   {16, 12, 12} => 4,
  ...>   {14, 14, 14} => 6,
  ...>   {50, 50, 50} => 200,
  ...>   {10, 10, 10} => 5,
  ...> })
  36
  """
  def closest_distance_to_most_nanobots(nanobots) do
    all_nanobots_cube = cube_containing_all_nanobots(nanobots)

    # split cube in half in each direction until we get to 1x1x1 cubes
    # split_cubes([all_nanobots_cube])
    Stream.unfold([all_nanobots_cube], fn cubes ->
      {best, rest} = best_cube(cubes)

      if cube_volume(best) > 1 do
        new_cubes =
          split_cube(best, nanobots)
          |> Enum.filter(fn {_, count} -> count > 0 end)

        {best, new_cubes ++ rest}
      else
        {best, rest}
      end
    end)
    |> Stream.filter(&(cube_volume(&1) == 1))
    |> Stream.chunk_by(fn {_, count} -> count end)
    |> Enum.at(0)
    |> Stream.map(fn {{xr, yr, zr}, _count} ->
      manhattan_distance({xr.first, yr.first, zr.first}, {0, 0, 0})
    end)
    |> Enum.min()
  end

  def split_cube({{xr, yr, zr}, _count}, nanobots) do
    for x <- split_range(xr),
        y <- split_range(yr),
        z <- split_range(zr) do
      {{x, y, z}, count_nanobots_in_range(nanobots, {x, y, z})}
    end
  end

  def split_range(%Range{first: first, last: last}) do
    mid = div(last - first, 2)
    [first..(first + mid), (first + mid + 1)..last]
  end

  @doc """
  iex> Day23.cube_volume({{0..0, 0..0, 0..0}, 12})
  1

  iex> Day23.cube_volume({{1..1, -3..-3, 10..10}, 12})
  1

  iex> Day23.cube_volume({{1..3, -5..-3, 10..12}, 12})
  27
  """
  def cube_volume({{xr, yr, zr}, _count}) do
    (xr.last - xr.first + 1) * (yr.last - yr.first + 1) * (zr.last - zr.first + 1)
  end

  def best_cube(cubes) do
    cubes
    |> Enum.reduce(nil, fn
      cube, nil ->
        {cube, []}

      cube, {best, rest} ->
        {_best_ranges, best_count} = best
        {_ranges, count} = cube

        if best_count > count do
          {best, [cube | rest]}
        else
          {cube, [best | rest]}
        end
    end)
  end

  #  def split_cubes(cubes) do
  #    {best_cube, cubes} = pop_best_cube()
  #  end

  @doc """
  iex> Day23.cube_containing_all_nanobots(%{
  ...>   {10, 12, 12} => 2,
  ...>   {12, 14, 12} => 2,
  ...>   {16, 12, 12} => 4,
  ...>   {14, 14, 14} => 6,
  ...>   {50, 50, 50} => 200,
  ...>   {10, 10, 10} => 5,
  ...> })
  {{10..50, 10..50, 10..50}, 6}
  """
  def cube_containing_all_nanobots(nanobots) do
    ranges =
      0..2
      |> Enum.map(fn i ->
        {min, max} =
          nanobots
          |> Enum.map(fn {pos, _radius} -> elem(pos, i) end)
          |> Enum.min_max()

        min..max
      end)
      |> Enum.reduce({}, fn range, acc -> Tuple.append(acc, range) end)

    count = nanobots |> count_nanobots_in_range(ranges)

    {ranges, count}
  end

  def count_nanobots_in_range(nanobots, ranges) do
    nanobots
    |> Enum.count(fn {pos, radius} ->
      in_range(closest_position(ranges, pos), pos, radius)
    end)
  end

  @doc """
  iex> Day23.closest_position({-10..20, -10..10, 0..10}, {10, 10, 10})
  {10, 10, 10}

  iex> Day23.closest_position({0..0, 0..0, 0..0}, {10, 10, 10})
  {0, 0, 0}

  iex> Day23.closest_position({-20..-10, -70..-50, -5..-5}, {10, 10, 10})
  {-10, -50, -5}

  iex> Day23.closest_position({-20..-10, -70..-50, -5..-5}, {-15, 10, 0})
  {-15, -50, -5}
  """
  def closest_position(cube_ranges, pos) do
    0..2
    |> Enum.reduce({}, fn i, acc ->
      rd = elem(cube_ranges, i)
      d = elem(pos, i)

      d =
        cond do
          d < rd.first -> rd.first
          d > rd.last -> rd.last
          true -> d
        end

      acc
      |> Tuple.append(d)
    end)
  end
end
