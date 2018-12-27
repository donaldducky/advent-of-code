defmodule Day22 do
  @moduledoc """
  Documentation for Day22.

  If the erosion level modulo 3 is 0, the region's type is rocky.
  If the erosion level modulo 3 is 1, the region's type is wet.
  If the erosion level modulo 3 is 2, the region's type is narrow.

  In rocky regions, you can use the climbing gear or the torch. You cannot use neither (you'll likely slip and fall).
  In wet regions, you can use the climbing gear or neither tool. You cannot use the torch (if it gets wet, you won't have a light source).
  In narrow regions, you can use the torch or neither tool. You cannot use the climbing gear (it's too bulky to fit).

  rocky    . → CT
  wet      = → CN
  narrow   | → TN

  C → .=
  T → .|
  N → =|
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
  iex> Day22.calculate_fastest_time(510, {0, 0})
  0

  iex> Day22.calculate_fastest_time(510, {0, 2})
  2

  iex> Day22.calculate_fastest_time(510, {10, 10})
  45
  """
  def calculate_fastest_time(depth, {tx, ty}) do
    starting_node = PathNode.new(0, 0, :torch)
    open = %{}
    visited = %{}

    open =
      open
      |> add_node(starting_node)

    state = TerrainState.new(depth, {tx, ty})

    calculate_fastest_time(state, open, visited, 1)
  end

  defp calculate_fastest_time(_, [], _, _) do
    raise "could not find path, empty open list"
  end

  defp calculate_fastest_time(state, open, visited, i) do
    # pick best node
    n =
      open
      |> select_best_node(state)

    if rem(i, 100) == 0 do
      i |> IO.inspect(label: "iteration")
      {n.x, n.y, n.cost} |> IO.inspect(label: "consdering")
      open |> Enum.count() |> IO.inspect(label: "open length")
    end

    if reached_end?(TerrainState.get_target(state), n) do
      # TODO if we reach the end without :torch, see if there is another shorter path
      # ie. evaluate other paths until cost = current cost - 1
      if n.equip != :torch do
        IO.puts("Reached end without :torch, perhaps there is a better path?")
        n.cost + 7
      else
        n.cost
      end
    else
      open = remove_node(open, n)
      visited = add_or_replace_node(visited, n)

      {state, nodes_to_add} =
        get_surrounding_node_positions(n)
        |> reject_out_of_bounds()
        |> convert_to_nodes(state, n)

      nodes_to_add =
        nodes_to_add
        |> reject_visited_nodes(visited)
        |> reject_too_far_east(state)

      open =
        nodes_to_add
        |> Enum.reduce(open, fn new_node, open -> add_or_replace_node(open, new_node) end)

      calculate_fastest_time(state, open, visited, i + 1)
    end
  end

  @doc """
  #iex> Day22.select_best_node(Day22.add_node(%{}, PathNode.new(0, 0, :torch)))
  #PathNode.new(0, 0, :torch)

  #iex> Day22.select_best_node((Day22.add_node(%{},
  #...>   PathNode.new(5, 5, :torch, 5, PathNode.new(0, 0, :torch))))
  #...>   |> Day22.add_node(PathNode.new(4, 3, :climbing, 3, PathNode.new(0, 0, :torch)))
  #...> )
  #PathNode.new(4, 3, :climbing, 3, PathNode.new(0,0, :torch))

  #iex> Day22.select_best_node((Day22.add_node(%{},
  #...>   PathNode.new(4, 3, :climbing, 3, PathNode.new(0, 0, :torch))))
  #...>   |> Day22.add_node(PathNode.new(4, 3, :torch, 3, PathNode.new(0, 0, :torch)))
  #...> )
  #PathNode.new(4, 3, :torch, 3, PathNode.new(0,0, :torch))
  """
  def select_best_node(node_map, state) do
    {tx, ty} = TerrainState.get_target(state)

    node_map
    |> Stream.map(fn {_k, n} -> n end)
    |> Enum.min_by(fn n ->
      # d = abs(n.x - tx) + abs(n.y - ty)
      # n.cost + equip_cost(n.equip) + d
      n.cost + equip_cost(n.equip)
    end)
  end

  def add_node(node_map, %PathNode{} = n) do
    node_map
    |> Map.put({n.x, n.y, n.equip}, n)
  end

  def add_or_replace_node(node_map, %PathNode{} = n) do
    key = {n.x, n.y, n.equip}
    p = Map.get(node_map, key)

    if p != nil and p.cost < n.cost do
      node_map
    else
      Map.put(node_map, key, n)
    end
  end

  def remove_node(node_map, %PathNode{} = n) do
    node_map
    |> Map.delete({n.x, n.y, n.equip})
  end

  def reject_visited_nodes(node_list, visited_node_map) do
    node_list
    |> Enum.reject(fn n ->
      pn = Map.get(visited_node_map, {n.x, n.y, n.equip})

      pn != nil and pn.cost < n.cost
    end)
  end

  def reject_too_far_east(node_list, state) do
    {tx, _} = TerrainState.get_target(state)

    node_list |> Enum.reject(fn n -> n.x > tx * 3 end)
  end

  @doc """
  iex> Day22.get_surrounding_node_positions(PathNode.new(0, 0, :torch))
  [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  iex> Day22.get_surrounding_node_positions(PathNode.new(10, 12, :torch))
  [{10, 13}, {10, 11}, {11, 12}, {9, 12}]
  """
  def get_surrounding_node_positions(%PathNode{x: x, y: y}) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
  end

  @doc """
  iex> Day22.reject_out_of_bounds([{0, 1}, {0, -1}, {1, 0}, {-1, 0}])
  [{0, 1}, {1, 0}]
  """
  def reject_out_of_bounds(coordinate_list) do
    coordinate_list
    |> Enum.reject(fn {x, y} -> x < 0 or y < 0 end)
  end

  def convert_to_nodes(coordinate_list, state, %PathNode{} = n) do
    acc = {state, []}

    coordinate_list
    |> Enum.reduce(acc, fn {x, y}, {state, node_list} ->
      {state, {_, _, from_type}} = TerrainState.get_terrain_info(state, {n.x, n.y})
      {state, {_, _, to_type}} = TerrainState.get_terrain_info(state, {x, y})

      {equip, cost} =
        if can_pass?(to_type, n.equip) do
          {n.equip, n.cost + 1}
        else
          # need to switch equipment based on current type and next type
          {swap_gear(n.equip, from_type, to_type), n.cost + 7 + 1}
        end

      new_node = PathNode.new(x, y, equip, cost, n)

      {state, [new_node | node_list]}
    end)
  end

  @doc """
  Prefer torch to other equipment, since we need it to find the target.
  """
  def equip_cost(:torch), do: -7
  def equip_cost(_), do: 0

  @doc """
  iex> Day22.reached_end?({10, 10}, PathNode.new(10, 10, :torch))
  true
  """
  def reached_end?({tx, ty}, %PathNode{} = n), do: tx == n.x and ty == n.y

  def can_pass?(0, equip) when equip == :torch or equip == :climbing, do: true
  def can_pass?(1, equip) when equip == :climbing or equip == :neither, do: true
  def can_pass?(2, equip) when equip == :torch or equip == :neither, do: true
  def can_pass?(_, _), do: false

  def swap_gear(:torch, 0, 1), do: :climbing
  def swap_gear(:torch, 2, 1), do: :neither
  def swap_gear(:climbing, 0, 2), do: :torch
  def swap_gear(:climbing, 1, 2), do: :neither
  def swap_gear(:neither, 1, 0), do: :climbing
  def swap_gear(:neither, 2, 0), do: :torch

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

  def second_half() do
    [[depth], [target_x, target_y]] =
      File.read!("input.txt")
      |> String.split("\n", trim: true)
      |> Enum.map(&LineParser.line/1)
      |> Enum.map(&(&1 |> elem(1)))

    calculate_fastest_time(depth, {target_x, target_y})
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
