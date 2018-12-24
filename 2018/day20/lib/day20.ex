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

  iex> Day20.parse_map_from_regex("^ENWWW(NEEE|SSE(EE|N))$")
  %{
    # ENWWW
    {0, 0} => {MapSet.new('E'), 0},
    {1, 0} => {MapSet.new('WN'), 1},
    {1, -1} => {MapSet.new('SW'), 2},
    {0, -1} => {MapSet.new('EW'), 3},
    {-1, -1} => {MapSet.new('EW'), 4},
    {-2, -1} => {MapSet.new('ENS'), 5},
      # (NEEE|
      {-2, -2} => {MapSet.new('SE'), 6},
      {-1, -2} => {MapSet.new('WE'), 7},
      {0, -2} => {MapSet.new('WE'), 8},
      {1, -2} => {MapSet.new('W'), 9},
      # SSE
      {-2, 0} => {MapSet.new('NS'), 6},
      {-2, 1} => {MapSet.new('NE'), 7},
      {-1, 1} => {MapSet.new('WEN'), 8},
        # (EE|
        {0, 1} => {MapSet.new('WE'), 9},
        {1, 1} => {MapSet.new('W'), 10},
        # N
        {-1, 0} => {MapSet.new('S'), 9},
  }
  """
  def parse_map_from_regex(input) do
    parse_char(input)
  end

  defp parse_char("^" <> rest), do: parse_char(rest, %{}, {0, 0}, 0, [])

  defp parse_char("(" <> rest, map, pos, doors_entered, stack) do
    parse_char(rest, map, pos, doors_entered, [{pos, doors_entered} | stack])
  end

  defp parse_char(
         "|" <> rest,
         map,
         _pos,
         _doors_entered,
         [{prev_pos, prev_doors_entered} | _remaining_stack] = stack
       ) do
    parse_char(rest, map, prev_pos, prev_doors_entered, stack)
  end

  defp parse_char(")" <> rest, map, _pos, _doors_entered, [
         {prev_pos, prev_doors_entered} | remaining_stack
       ]) do
    parse_char(rest, map, prev_pos, prev_doors_entered, remaining_stack)
  end

  defp parse_char("$", map, _pos, _doors_entered, _stack), do: map

  defp parse_char(<<cp::utf8>> <> rest, map, {x, y} = pos, doors_entered, stack) do
    {opposite_char, next_pos} =
      case cp do
        ?N -> {?S, {x, y - 1}}
        ?S -> {?N, {x, y + 1}}
        ?E -> {?W, {x + 1, y}}
        ?W -> {?E, {x - 1, y}}
        _ -> raise("unknown char #{<<cp::utf8>>}")
      end

    map =
      map
      |> add_to_map(pos, cp, doors_entered)
      |> add_to_map(next_pos, opposite_char, doors_entered + 1)

    parse_char(rest, map, next_pos, doors_entered + 1, stack)
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

  iex> Day20.parse_map_from_regex("^ENWWW(NEEE|SSE(EE|N))$") |> Day20.most_doors_count()
  10

  iex> Day20.parse_map_from_regex("^ENNWSWW(NEWS|)SSSEEN(WNSE|)EE(SWEN|)NNN$") |> Day20.most_doors_count()
  18

  iex> Day20.parse_map_from_regex("^ESSWWN(E|NNENN(EESS(WNSE|)SSS|WWWSSSSE(SW|NNNE)))$") |> Day20.most_doors_count()
  23

  iex> Day20.parse_map_from_regex("^WSSEESWWWNW(S|NENNEEEENN(ESSSSW(NWSW|SSEN)|WSWWN(E|WWS(E|SS))))$") |> Day20.most_doors_count()
  31
  """
  def most_doors_count(map) do
    map
    |> Stream.map(fn {_pos, {_doors, doors_from_origin}} -> doors_from_origin end)
    |> Enum.max()
  end

  def at_least_n_doors_count(map, min_doors) do
    map
    |> Stream.map(fn {_pos, {_doors, doors_from_origin}} -> doors_from_origin end)
    |> Stream.filter(&(&1 >= min_doors))
    |> Enum.count()
  end

  def first_half() do
    File.read!("input.txt")
    |> String.trim()
    |> parse_map_from_regex()
    |> most_doors_count()
  end

  def second_half() do
    File.read!("input.txt")
    |> String.trim()
    |> parse_map_from_regex()
    |> at_least_n_doors_count(1000)
  end
end
