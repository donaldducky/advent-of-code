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
  def in_range({x1, y1, z1}, {x2, y2, z2}, r) do
    abs(x1 - x2) + abs(y1 - y2) + abs(z1 - z2) <= r
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
end
