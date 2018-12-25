defmodule Day22 do
  @moduledoc """
  Documentation for Day22.
  """

  @doc """
  iex> Day22.calculate_erosion_levels_and_risk(510, {2, 2})
  {
    %{
      {0, 0} => 510,
      {1, 0} => 17317,
      {2, 0} => 13941,
      {0, 1} => 8415,
      {1, 1} => 1805,
      {2, 1} => 15997,
      {0, 2} => 16320,
      {1, 2} => 11113,
      {2, 2} => 510,
    },
    5
  }
  """
  def calculate_erosion_levels_and_risk(depth, {tx, ty}) do
    erosion_levels = %{}
    risk = 0

    Enum.reduce(0..ty, {erosion_levels, risk}, fn y, acc ->
      Enum.reduce(0..tx, acc, fn x, {erosion_levels, risk} ->
        erosion_level =
          geologic_index({x, y}, {tx, ty}, erosion_levels)
          |> erosion_level(depth)

        {Map.put(erosion_levels, {x, y}, erosion_level), risk + rem(erosion_level, 3)}
      end)
    end)
  end

  @doc """
  iex> Day22.calculate_risk(510, {10, 10})
  114
  """
  def calculate_risk(depth, target) do
    {_erosion_levels, risk} = calculate_erosion_levels_and_risk(depth, target)
    risk
  end

  def geologic_index({0, 0}, _, _), do: 0
  def geologic_index({x, y}, {tx, ty}, _) when x == tx and y == ty, do: 0
  def geologic_index({x, 0}, _, _), do: x * 16807
  def geologic_index({0, y}, _, _), do: y * 48271

  def geologic_index({x, y}, _, erosion_levels) do
    Map.get(erosion_levels, {x - 1, y}) * Map.get(erosion_levels, {x, y - 1})
  end

  def erosion_level(geologic_index, depth) do
    rem(geologic_index + depth, 20183)
  end

  @doc """
  iex> Day22.first_half()
  7915
  """
  def first_half() do
    [[depth], [target_x, target_y]] =
      File.read!("input.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&LineParser.line/1)
      |> Enum.map(&(&1 |> elem(1)))

    calculate_risk(depth, {target_x, target_y})
  end
end

defmodule LineParser do
  import NimbleParsec

  depth =
    ignore(string("depth: "))
    |> integer(min: 1)

  target =
    ignore(string("target: "))
    |> integer(min: 1)
    |> ignore(string(","))
    |> integer(min: 1)

  line =
    choice([
      depth,
      target
    ])

  defparsec(:line, line)
end
