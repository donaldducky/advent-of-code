defmodule Day17 do
  @moduledoc """
  Documentation for Day17.
  """

  @tile_map %{
    spring: "+",
    clay: "#",
    sand: ".",
    still_water: "~",
    flowing_water: "|"
  }
  @map_tile %{
    "+" => :spring,
    "#" => :clay,
    "." => :sand,
    "~" => :still_water,
    "|" => :flowing_water
  }
  @directions %{
    left: {-1, 0},
    right: {1, 0},
    down: {0, 1},
    up: {0, -1}
  }

  @doc """
  iex> Day17.parse_map([
  ...> "y=7, x=495..501",
  ...> "x=501, y=3..7",
  ...> ])
  %{
    {500, 0} => :spring,
    {495, 7} => :clay,
    {496, 7} => :clay,
    {497, 7} => :clay,
    {498, 7} => :clay,
    {499, 7} => :clay,
    {500, 7} => :clay,
    {501, 7} => :clay,
    {501, 3} => :clay,
    {501, 4} => :clay,
    {501, 5} => :clay,
    {501, 6} => :clay,
  }
  """
  def parse_map(lines) do
    lines
    |> Stream.map(&LineParser.line/1)
    |> Enum.reduce(%{}, fn
      {:ok, ["y", y, "x", x1, x2], _, _, _, _}, map ->
        x1..x2 |> Enum.reduce(map, fn x, map -> Map.put(map, {x, y}, :clay) end)

      {:ok, ["x", x, "y", y1, y2], _, _, _, _}, map ->
        y1..y2 |> Enum.reduce(map, fn y, map -> Map.put(map, {x, y}, :clay) end)
    end)
    |> Map.put({500, 0}, :spring)
  end

  @doc """
  For x, we only care about 1 left and 1 right.
  For y, we start at 1, after the spring flows, to the max y.
  iex> Day17.map_bounds(%{
  ...>   {500, 0} => :spring,
  ...>   {495, 7} => :clay,
  ...>   {496, 7} => :clay,
  ...>   {497, 7} => :clay,
  ...>   {498, 7} => :clay,
  ...>   {499, 7} => :clay,
  ...>   {500, 7} => :clay,
  ...>   {501, 7} => :clay,
  ...>   {501, 3} => :clay,
  ...>   {501, 4} => :clay,
  ...>   {501, 5} => :clay,
  ...>   {501, 6} => :clay,
  ...> })
  %{x_min: 494, x_max: 502, y_min: 1, y_max: 7}
  """
  def map_bounds(map) do
    map
    |> Stream.map(fn {{x, y}, _v} -> {x, y} end)
    |> Enum.reduce(%{}, fn {x, y}, bounds ->
      bounds
      |> Map.update(:x_min, x, fn
        previous_x when x < previous_x -> x
        previous_x -> previous_x
      end)
      |> Map.update(:x_max, x, fn
        previous_x when x > previous_x -> x
        previous_x -> previous_x
      end)
      |> Map.update(:y_max, y, fn
        previous_y when y > previous_y -> y
        previous_y -> previous_y
      end)
    end)
    |> Map.update!(:x_min, &(&1 - 1))
    |> Map.update!(:x_max, &(&1 + 1))
    |> Map.put(:y_min, 1)
  end

  @doc """
  iex> Day17.draw_map(%{
  ...>   {500, 0} => :spring,
  ...>   {495, 7} => :clay,
  ...>   {496, 7} => :clay,
  ...>   {497, 7} => :clay,
  ...>   {498, 7} => :clay,
  ...>   {499, 7} => :clay,
  ...>   {500, 7} => :clay,
  ...>   {501, 7} => :clay,
  ...>   {501, 3} => :clay,
  ...>   {501, 4} => :clay,
  ...>   {501, 5} => :clay,
  ...>   {501, 6} => :clay,
  ...> })
  "......+..\n.........\n.........\n.......#.\n.......#.\n.......#.\n.......#.\n.#######.\n"
  """
  def draw_map(map) do
    bounds = map |> map_bounds()
    x_min = Map.get(bounds, :x_min)
    x_max = Map.get(bounds, :x_max)
    y_min = 0
    y_max = Map.get(bounds, :y_max)

    Enum.reduce(y_min..y_max, "", fn y, output ->
      output =
        Enum.reduce(x_min..x_max, output, fn x, output ->
          output <> Map.get(@tile_map, Map.get(map, {x, y}, :sand))
        end)

      output <> "\n"
    end)
  end

  @doc ~S"""
  iex> Day17.read_map("......+..\n.........\n.........\n.......#.\n.......#.\n.......#.\n.......#.\n.#######.\n")
  %{
    {500, 0} => :spring,
    {495, 7} => :clay,
    {496, 7} => :clay,
    {497, 7} => :clay,
    {498, 7} => :clay,
    {499, 7} => :clay,
    {500, 7} => :clay,
    {501, 7} => :clay,
    {501, 3} => :clay,
    {501, 4} => :clay,
    {501, 5} => :clay,
    {501, 6} => :clay,
  }
  """
  def read_map(map_string) do
    [first_line | rest] =
      map_string
      |> String.split("\n", trim: true)
      |> Enum.map(&String.codepoints/1)

    spring_x = 500
    x_offset = spring_x - (first_line |> Enum.find_index(fn c -> c == "+" end))

    Enum.with_index([first_line | rest])
    |> Enum.reduce(%{}, fn {line, y}, map ->
      Enum.with_index(line)
      |> Enum.reduce(map, fn
        {c, _x}, map when c == "." ->
          map

        {c, x}, map ->
          Map.put(map, {x + x_offset, y}, Map.get(@map_tile, c))
      end)
    end)
  end

  def generate_water_flow(map) do
    bounds = map |> map_bounds()

    x_min = Map.get(bounds, :x_min)
    x_max = Map.get(bounds, :x_max)
    y_min = 0
    y_max = Map.get(bounds, :y_max)

    {{spring_x, spring_y}, :spring} = map |> Enum.find(fn {{_x, _y}, v} -> v == :spring end)

    map = step_water_flow(map, {x_min, x_max, y_min, y_max}, [{spring_x, spring_y, {0, 1}}])

    draw_map(map)
    |> IO.puts()

    map
  end

  def step_water_flow(map, {_x_min, _x_max, _y_min, y_max} = bounds, [{_x, y, {_vx, vy}} | rest])
      when y + vy > y_max do
    step_water_flow(map, bounds, rest)
  end

  def step_water_flow(map, bounds, [{x, y, {vx, vy} = direction} | rest]) do
    x2 = x + vx
    y2 = y + vy

    map =
      case Map.get(map, {x2, y2}) do
        nil ->
          map = Map.put(map, {x2, y2}, :flowing_water)
          step_water_flow(map, bounds, [{x2, y2, direction} | rest])

        tile ->
          tile |> IO.inspect(label: "unhandled tile")
          map
      end

    map
  end

  def step_water_flow(map, bounds, []) do
    map
  end

  @doc """

  """
  def count_water_tiles(map) do
    bounds = map |> map_bounds()
    x_min = Map.get(bounds, :x_min)
    x_max = Map.get(bounds, :x_max)
    y_min = 0
    y_max = Map.get(bounds, :y_max)

    Enum.reduce(y_min..y_max, 0, fn y, sum ->
      Enum.reduce(x_min..x_max, sum, fn x, sum ->
        case Map.get(map, {x, y}) do
          :still_water -> sum + 1
          :flowing_water -> sum + 1
          _ -> sum
        end
      end)
    end)
  end

  @doc """
  "iex> Day17.first_half()
  "1
  """
  def first_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_map()
    |> generate_water_flow()
    |> count_water_tiles()
  end
end

defmodule LineParser do
  import NimbleParsec

  # "y=7, x=495..501"
  # "x=501, y=3..7"
  x_line =
    string("x")
    |> ignore(string("="))
    |> integer(min: 1)
    |> ignore(string(", "))
    |> string("y")
    |> ignore(string("="))
    |> integer(min: 1)
    |> ignore(string(".."))
    |> integer(min: 1)

  y_line =
    string("y")
    |> ignore(string("="))
    |> integer(min: 1)
    |> ignore(string(", "))
    |> string("x")
    |> ignore(string("="))
    |> integer(min: 1)
    |> ignore(string(".."))
    |> integer(min: 1)

  line = choice([x_line, y_line])

  defparsec(:line, line)
end
