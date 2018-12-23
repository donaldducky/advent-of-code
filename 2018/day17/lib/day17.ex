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
  %{x_min: 494, x_max: 502, y_min: 3, y_max: 7}
  """
  def map_bounds(map) do
    map
    |> Stream.filter(fn {_, v} -> v == :clay end)
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
      |> Map.update(:y_min, y, fn
        previous_y when y < previous_y -> y
        previous_y -> previous_y
      end)
      |> Map.update(:y_max, y, fn
        previous_y when y > previous_y -> y
        previous_y -> previous_y
      end)
    end)
    |> Map.update!(:x_min, &(&1 - 1))
    |> Map.update!(:x_max, &(&1 + 1))
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
  ".......#.\n.......#.\n.......#.\n.......#.\n.#######.\n"
  """
  def draw_map(map) do
    bounds = map |> map_bounds()
    x_min = Map.get(bounds, :x_min)
    x_max = Map.get(bounds, :x_max)
    y_min = Map.get(bounds, :y_min)
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
    y_max =
      map
      |> map_bounds()
      |> Map.get(:y_max)

    {{spring_x, spring_y}, :spring} = map |> Enum.find(fn {{_x, _y}, v} -> v == :spring end)

    map = step_water_flow(map, y_max, [{spring_x, spring_y}])

    draw_map(map)
    |> IO.puts()

    map
  end

  def step_water_flow(map, y_max, [{_x, y} | rest])
      when y + 1 > y_max do
    step_water_flow(map, y_max, rest)
  end

  def step_water_flow(map, _y_max, []), do: map

  def step_water_flow(map, y_max, [{x, y} | rest]) do
    down_tile = Map.get(map, {x, y + 1})

    case down_tile do
      nil ->
        map = Map.put(map, {x, y + 1}, :flowing_water)
        step_water_flow(map, y_max, [{x, y + 1} | rest])

      tile when tile == :clay or tile == :still_water ->
        blocked_left? = is_blocked?(map, {x, y}, {-1, 0})
        blocked_right? = is_blocked?(map, {x, y}, {1, 0})

        case {blocked_left?, blocked_right?} do
          {true, true} ->
            # fill row and move back up
            fill_row(map, {x, y})
            |> step_water_flow(y_max, [{x, y - 1} | rest])

          {true, false} ->
            {map, {next_x, next_y}} =
              map
              |> fill_left({x, y}, :flowing_water)
              |> flow_right({x, y})

            step_water_flow(map, y_max, [{next_x, next_y} | rest])

          {false, true} ->
            {map, {next_x, next_y}} =
              map
              |> fill_right({x, y}, :flowing_water)
              |> flow_left({x, y})

            step_water_flow(map, y_max, [{next_x, next_y} | rest])

          {false, false} ->
            {map, {right_x, right_y}} =
              map
              |> flow_right({x, y})

            {map, {left_x, left_y}} =
              map
              |> flow_left({x, y})

            step_water_flow(map, y_max, [
              {left_x, left_y},
              {right_x, right_y} | rest
            ])
        end

      :flowing_water ->
        step_water_flow(map, y_max, rest)

      tile ->
        tile |> IO.inspect(label: "unhandled tile")
        map
    end
  end

  def flow(map, {x, y}, {vx, _vy}) do
    Stream.iterate(0, &(&1 + vx))
    |> Enum.reduce_while(map, fn i, map ->
      map = Map.put(map, {x + i, y}, :flowing_water)
      down_tile = Map.get(map, {x + i, y + 1})

      if down_tile == :clay or down_tile == :still_water do
        {:cont, map}
      else
        map = Map.put(map, {x + i, y}, :flowing_water)
        {:halt, {map, {x + i, y}}}
      end
    end)
  end

  def flow_right(map, {x, y}) do
    flow(map, {x, y}, {1, 0})
  end

  def flow_left(map, {x, y}) do
    flow(map, {x, y}, {-1, 0})
  end

  def is_blocked?(map, {x, y}, {vx, vy} = direction) when abs(vx) == 1 and vy == 0 do
    if Map.get(map, {x + vx, y}) == :clay do
      true
    else
      # can we flow down?
      down_tile = Map.get(map, {x + vx, y + 1})

      if down_tile == :clay or down_tile == :still_water do
        is_blocked?(map, {x + vx, y}, direction)
      else
        false
      end
    end
  end

  @doc """
  Fill in a given direction until blocked by clay.
  """
  def fill(map, {x, y}, {vx, vy}, fill_with) when vy == 0 do
    Stream.iterate(0 + vx, &(&1 + vx))
    |> Enum.reduce_while(map, fn i, map ->
      if Map.get(map, {x + i, y}) == :clay do
        {:halt, map}
      else
        {:cont, Map.put(map, {x + i, y}, fill_with)}
      end
    end)
  end

  def fill_left(map, {x, y}, fill_with) do
    fill(map, {x, y}, {-1, 0}, fill_with)
  end

  def fill_right(map, {x, y}, fill_with) do
    fill(map, {x, y}, {1, 0}, fill_with)
  end

  def fill_row(map, {x, y}) do
    map
    |> fill_left({x, y}, :still_water)
    |> fill_right({x, y}, :still_water)
    |> Map.put({x, y}, :still_water)
  end

  @doc """

  """
  def count_water_tiles(map) do
    bounds = map_bounds(map)
    y_min = Map.get(bounds, :y_min)

    map
    |> Stream.filter(fn {{_x, y}, _tile} -> y >= y_min end)
    |> Enum.count(fn {_, tile} -> tile == :still_water or tile == :flowing_water end)
  end

  @doc """

  """
  def count_still_water_tiles(map) do
    bounds = map_bounds(map)
    y_min = Map.get(bounds, :y_min)

    map
    |> Stream.filter(fn {{_x, y}, _tile} -> y >= y_min end)
    |> Enum.count(fn {_, tile} -> tile == :still_water end)
  end

  @doc """
  #iex> Day17.first_half()
  #1
  """
  def first_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_map()
    |> write_map("out-a.txt")
    |> generate_water_flow()
    |> write_map("out-b.txt")
    |> count_water_tiles()
  end

  @doc """
  #iex> Day17.first_half()
  #1
  """
  def second_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_map()
    |> generate_water_flow()
    |> count_still_water_tiles()
  end

  def write_map(map, filename) do
    File.write!(filename, draw_map(map))

    map
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
