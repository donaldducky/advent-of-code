defmodule Day25 do
  @moduledoc """
  Documentation for Day25.
  """

  @doc """
  iex> Day25.count_constellations([
  ...>   {0, 0, 0, 0},
  ...>   {3, 0, 0, 0},
  ...>   {0, 3, 0, 0},
  ...>   {0, 0, 3, 0},
  ...>   {0, 0, 0, 3},
  ...>   {0, 0, 0, 6},
  ...>   {9, 0, 0, 0},
  ...>   {12, 0, 0, 0},
  ...> ])
  2

  iex> Day25.count_constellations([
  ...>   {0, 0, 0, 0},
  ...>   {3, 0, 0, 0},
  ...>   {0, 3, 0, 0},
  ...>   {0, 0, 3, 0},
  ...>   {0, 0, 0, 3},
  ...>   {0, 0, 0, 6},
  ...>   {6, 0, 0, 0},
  ...>   {9, 0, 0, 0},
  ...>   {12, 0, 0, 0},
  ...> ])
  1

  iex> Day25.count_constellations([
  ...>   {-1, 2, 2, 0},
  ...>   {0, 0, 2, -2},
  ...>   {0, 0, 0, -2},
  ...>   {-1, 2, 0, 0},
  ...>   {-2, -2, -2, 2},
  ...>   {3, 0, 2, -1},
  ...>   {-1, 3, 2, 2},
  ...>   {-1, 0, -1, 0},
  ...>   {0, 2, 1, -2},
  ...>   {3, 0, 0, 0},
  ...> ])
  4
  """
  def count_constellations(points) do
    explore(points)
    |> IO.inspect(label: "constellations found")
    |> Enum.count()
  end

  def explore(points) do
    constellations = []
    explore(points, constellations)
  end

  defp explore([], constellations),
    do: constellations |> IO.inspect(label: "No more constellations found")

  defp explore([point], constellations) do
    last_constellation =
      MapSet.new([point])
      |> IO.inspect(label: "last")

    [last_constellation | constellations]
  end

  defp explore([point | points], constellations) do
    {constellation, remaining} = explore_constellation(point, points)

    explore(remaining, [constellation | constellations])
  end

  def explore_constellation(point, points) do
    point |> IO.inspect(label: "Exploring constellation")
    constellation = [point]
    visited = MapSet.new([point])

    unvisited_points = closest_points_to(point, visited)

    {in_constellation, not_in_constellation, visited} =
      visit_remaining(unvisited_points, points, visited)

    explore_constellation(
      in_constellation,
      not_in_constellation,
      constellation ++ in_constellation,
      visited
    )
  end

  def explore_constellation([], points, constellation, _visited), do: {constellation, points}
  def explore_constellation(_new_points, [], constellation, _visited), do: {constellation, []}

  def explore_constellation(new_points, points, constellation, visited) do
    unvisited_points =
      new_points
      |> Enum.reduce(MapSet.new(), fn point, acc ->
        MapSet.union(acc, closest_points_to(point, visited))
      end)

    {in_constellation, not_in_constellation, visited} =
      visit_remaining(unvisited_points, points, visited)

    explore_constellation(
      in_constellation,
      not_in_constellation,
      constellation ++ in_constellation,
      visited
    )
  end

  def visit_remaining(unvisited_points, points, visited) do
    found_map =
      points
      |> Enum.group_by(fn p -> MapSet.member?(unvisited_points, p) end)

    in_constellation =
      Map.get(found_map, true, [])
      |> IO.inspect(label: "found new points in constellation")

    not_in_constellation =
      Map.get(found_map, false, [])
      |> IO.inspect(label: "points left to consider")

    visited = MapSet.union(visited, unvisited_points)

    {in_constellation, not_in_constellation, visited}
  end

  def closest_points_to({a, b, c, d}, visited) do
    expansion_points()
    |> Enum.reduce(MapSet.new(), fn {da, db, dc, dd}, acc ->
      p2 = {a + da, b + db, c + dc, d + dd}

      if MapSet.member?(visited, p2) do
        acc
      else
        MapSet.put(acc, p2)
      end
    end)
  end

  def expansion_points() do
    origin = {0, 0, 0, 0}

    1..3
    |> Enum.reduce(MapSet.new([origin]), fn _i, acc ->
      acc
      |> Enum.reduce(acc, fn {a, b, c, d}, acc ->
        [
          {1, 0, 0, 0},
          {0, 1, 0, 0},
          {0, 0, 1, 0},
          {0, 0, 0, 1},
          {-1, 0, 0, 0},
          {0, -1, 0, 0},
          {0, 0, -1, 0},
          {0, 0, 0, -1}
        ]
        |> Enum.map(fn {a2, b2, c2, d2} -> {a + a2, b + b2, c + c2, d + d2} end)
        |> Enum.into(acc)
      end)
    end)
    |> MapSet.delete(origin)
  end

  def parse_input(lines) do
    lines
    |> Enum.map(&LineParser.line/1)
    |> Enum.map(fn {:ok, tokens, _, _, _, _} ->
      tokens
      |> Enum.map(fn
        {:positive, n} -> n
        {:negative, n} -> -n
      end)
      |> List.to_tuple()
    end)
  end

  def first_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_input()
    |> count_constellations()
  end
end
