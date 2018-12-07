defmodule Day6 do
  @moduledoc """
  Documentation for Day6.
  """
  @type coordinate :: {integer, integer}
  @type coordinate_list :: list(coordinate)

  @doc """
  Calculate largest area size of nearest coordinates by coordinate.

  aaaaa.cccc
  aAaaa.cccc
  aaaddecccc
  aadddeccCc
  ..dDdeeccc
  bb.deEeecc
  bBb.eeee..
  bbb.eeefff
  bbb.eeffff
  bbb.ffffFf

  ## Examples

      iex> Day6.largest_area_size([ {1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9} ])
      17

  """
  @spec largest_area_size(coordinate_list) :: integer
  def largest_area_size(coords) do
    bounds =
      coords
      |> calculate_bounds()

    Enum.reduce(bounds.min_x..bounds.max_x, [], fn x, acc ->
      Enum.reduce(bounds.min_y..bounds.max_y, acc, fn y, acc ->
        min_coordinate =
          coords
          |> min_coordinate_distance({x, y})

        if min_coordinate == :tie do
          acc
        else
          [{{x, y}, min_coordinate} | acc]
        end
      end)
    end)
    |> Enum.group_by(fn {_, c} -> c end)
    |> Enum.reject(fn {_c, point_coordinate_pairs} ->
      point_coordinate_pairs
      |> Enum.any?(fn {{x, y}, _coord} ->
        x == bounds.min_x || x == bounds.max_x || y == bounds.min_y || y == bounds.max_y
      end)
    end)
    |> Enum.map(fn {k, v} -> {k, length(v)} end)
    |> Enum.max_by(fn {_k, l} -> l end)
    |> elem(1)
  end

  @doc """
  Calculate manhattan distance between two points

  ## Examples

      iex> Day6.distance({0, 0}, {1, 1})
      2
      iex> Day6.distance({1, 1}, {1, 1})
      0
      iex> Day6.distance({5, 1}, {1, 1})
      4
      iex> Day6.distance({5, 1}, {5, 5})
      4
  """
  @spec distance(coordinate, coordinate) :: integer
  def distance({x, y}, {x2, y2}) do
    abs(x - x2) + abs(y - y2)
  end

  @doc """
  Calculate minimum distance between a list of coordinates and a coordinate.
  In the case there are multiple that meet the criteria, there is a tie.

  ## Examples

      iex> Day6.min_coordinate_distance([{5, 5}, {5, 1}, {0, 0}, {1, 1}], {1, 1})
      {1, 1}

      iex> Day6.min_coordinate_distance([{1, 1}, {5, 5}], {5, 1})
      :tie
  """
  @spec min_coordinate_distance(coordinate_list, coordinate) :: coordinate | :tie
  def min_coordinate_distance(coords, {x, y}) do
    coords
    |> Stream.map(fn coord -> {coord, distance(coord, {x, y})} end)
    |> Enum.reduce(fn
      {_c, d} = pair, {_acc_c, acc_d} when d < acc_d ->
        pair

      {_c, d}, {_acc_c, acc_d} when d == acc_d ->
        {:tie, d}

      _pair, acc ->
        acc
    end)
    |> elem(0)
  end

  @doc """
  Calculate bounds

  ## Examples

      iex> Day6.calculate_bounds([ {1, 1}, {1, 6}, {8, 3}, {3, 4}, {5, 5}, {8, 9} ])
      %{min_x: 1, max_x: 8, min_y: 1, max_y: 9}

  """
  @spec calculate_bounds(coordinate_list) :: integer
  def calculate_bounds(input) do
    min_x = input |> Enum.min_by(fn {x, _y} -> x end) |> elem(0)
    max_x = input |> Enum.max_by(fn {x, _y} -> x end) |> elem(0)
    min_y = input |> Enum.min_by(fn {_x, y} -> y end) |> elem(1)
    max_y = input |> Enum.max_by(fn {_x, y} -> y end) |> elem(1)

    %{min_x: min_x, max_x: max_x, min_y: min_y, max_y: max_y}
  end

  @spec read_input() :: Enumerable.t()
  def read_input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&LineParser.coordinate/1)
    |> Stream.map(fn {:ok, [x, y], _, _, _, _} -> {x, y} end)
  end
end

defmodule LineParser do
  import NimbleParsec

  coord =
    integer(min: 1)
    |> ignore(string(", "))
    |> integer(min: 1)

  defparsec(:coordinate, coord)
end
