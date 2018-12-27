defmodule Day22 do
  @moduledoc """
  Documentation for Day22.

  If the erosion level modulo 3 is 0, the region's type is rocky.
  If the erosion level modulo 3 is 1, the region's type is wet.
  If the erosion level modulo 3 is 2, the region's type is narrow.
  """

  @doc """
  iex> Day22.calculate_risk(510, {10, 10})
  114
  """
  def calculate_risk(depth, {tx, ty}) do
    state = TerrainState.new(depth, {tx, ty})

    risk = 0

    {_state, risk} =
      Enum.reduce(0..ty, {state, risk}, fn y, acc ->
        Enum.reduce(0..tx, acc, fn x, {state, risk} ->
          {state, {_, _, type}} = TerrainState.get_terrain_info(state, {x, y})

          {state, risk + type}
        end)
      end)

    risk
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
