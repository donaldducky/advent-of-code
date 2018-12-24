defmodule Day20 do
  @moduledoc """
  Documentation for Day20.
  """

  @doc ~S"""
  iex> Day20.parse_map_from_regex("^WNE$")
  %{
    {0, 0} => {MapSet.new('W'), 0},
    {-1, 0} => {MapSet.new('EN'), 1},
    {-1, -1} => {MapSet.new('SE'), 2},
    {0, -1} => {MapSet.new('W'), 3},
  }
  """
  def parse_map_from_regex(input) do
    parse_char(input)
  end

  defp parse_char("^" <> input), do: parse_char(input, %{}, {0, 0}, 0)
  defp parse_char("$", map, _pos, _doors_entered), do: map

  defp parse_char(<<cp::utf8>> <> rest, map, {x, y} = pos, doors_entered) do
    {opposite_char, next_pos} =
      case cp do
        ?N -> {?S, {x, y - 1}}
        ?S -> {?N, {x, y + 1}}
        ?E -> {?W, {x + 1, y}}
        ?W -> {?E, {x - 1, y}}
      end

    map =
      map
      |> add_to_map(pos, cp, doors_entered)
      |> add_to_map(next_pos, opposite_char, doors_entered + 1)

    parse_char(rest, map, next_pos, doors_entered + 1)
  end

  defp add_to_map(map, pos, char, doors_entered) do
    map
    |> Map.update(pos, {MapSet.new([char]), doors_entered}, fn {doors, doors_from_origin} ->
      {MapSet.put(doors, char), min(doors_from_origin, doors_entered + 1)}
    end)
  end

  @doc """
  iex> Day20.parse_map_from_regex("^WNE$") |> Day20.most_doors_count()
  3
  """
  def most_doors_count(map) do
    map
    |> Stream.map(fn {_pos, {_doors, doors_from_origin}} -> doors_from_origin end)
    |> Enum.max()
  end

  def first_half() do
    File.read!("input.txt")
    |> String.trim()
    |> parse_map_from_regex()
    |> most_doors_count()
  end
end
