defmodule Day15 do
  @moduledoc """
  Documentation for Day15.

  walls (#)
  open cavern (.)
  Goblin (G)
  Elf (E)

  Each unit, either Goblin or Elf, has 3 attack power and starts with 200 hit points.
  """

  @type_map %{:goblin => :goblins, :elf => :elves}
  @enemy_map %{:goblin => :elves, :elf => :goblins}

  @doc """
  Given lines of a map, parse the initial state.
  """
  def parse_map(lines) do
    lines
    |> Enum.map(&String.to_charlist/1)
    |> Enum.with_index()
    |> Enum.reduce(
      %{goblins: MapSet.new(), elves: MapSet.new(), width: 0, height: 0},
      fn {list_of_chars, y}, map ->
        list_of_chars
        |> Enum.with_index()
        |> Enum.reduce(map, fn {c, x}, map ->
          case c do
            ?# ->
              Map.put(map, {x, y}, :wall)

            ?G ->
              Map.put(map, {x, y}, {:goblin, 200})
              |> Map.update(:goblins, MapSet.new([{x, y}]), fn goblins ->
                MapSet.put(goblins, {x, y})
              end)

            ?E ->
              map
              |> Map.put({x, y}, {:elf, 200})
              |> Map.update(:elves, MapSet.new([{x, y}]), fn elves ->
                MapSet.put(elves, {x, y})
              end)

            _ ->
              map
          end
          |> Map.update(:width, x + 1, &max(x + 1, &1))
        end)
        |> Map.put(:height, y + 1)
      end
    )
  end

  def combat_outcome(input) do
    state =
      input
      |> String.split("\n", trim: true)
      |> parse_map()

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(state, fn rounds_completed, state ->
      # state |> draw_map(rounds_completed - 1)

      state = combat_round(state)

      if Map.get(state, :ended) do
        # which team won?
        goblins = Map.get(state, :goblins)
        elves = Map.get(state, :elves)

        unit_positions =
          if MapSet.size(goblins) == 0 do
            elves
          else
            goblins
          end

        # state |> IO.inspect(label: "end state")
        # state |> draw_map(rounds_completed)

        hp_sum =
          unit_positions
          |> Enum.map(fn pos ->
            {_type, hp} = Map.get(state, pos)
            hp
          end)
          |> Enum.sum()

        sum =
          if Map.get(state, :full_round) do
            hp_sum * rounds_completed
          else
            hp_sum * (rounds_completed - 1)
          end

        {:halt, sum}
      else
        {:cont, state}
      end
    end)
  end

  @doc """
  Calculate one round of action.
  """
  def combat_round(state) do
    state
    |> calculate_turn_order()
    |> Enum.reduce(state, &perform_action/2)
  end

  @doc """
  Calculate the order in which units take turns.
  Prioritized by reading order (top -> down, left -> right).
  """
  def calculate_turn_order(%{goblins: goblins, elves: elves}) do
    MapSet.union(goblins, elves)
    |> MapSet.to_list()
    |> Enum.sort_by(fn {x, y} -> {y, x} end)
  end

  @doc """
  Perform an action.
  1) find nearest target
  2) if adjacent, attack
  2a) tie: hp equal, pick lower hp
  2b) tie: pick based on reading order
  3) move towards nearest enemy using shortest path / reading order
  """
  def perform_action(unit_position, state) do
    cond do
      Map.get(state, :ended) ->
        state
        |> Map.put(:full_round, false)

      Map.get(state, unit_position) == nil ->
        state

      true ->
        {unit_type, _} = state |> Map.get(unit_position)

        enemy_type = Map.get(@enemy_map, unit_type)
        ally_type = Map.get(@type_map, unit_type)

        ally_positions = Map.get(state, ally_type)
        enemy_positions = Map.get(state, enemy_type)

        adjacent_enemy =
          find_adjacent_enemies(unit_position, enemy_positions)
          |> Enum.map(fn {x, y} = pos ->
            {type, hp} = Map.get(state, pos)
            {hp, y, x, type}
          end)
          |> Enum.filter(fn {hp, _y, _x, _type} -> hp > 0 end)
          |> Enum.sort()
          |> Enum.find(& &1)

        if adjacent_enemy == nil do
          state = move_unit(unit_position, state, enemy_positions)
          # TODO move_unit should return position to move to
          new_ally_positions = Map.get(state, ally_type)

          case MapSet.difference(new_ally_positions, ally_positions) |> MapSet.to_list() do
            [new_position | _] ->
              enemy_positions = Map.get(state, enemy_type)

              # attack if units within range
              adjacent_enemy =
                find_adjacent_enemies(new_position, enemy_positions)
                |> Enum.map(fn {x, y} = pos ->
                  {type, hp} = Map.get(state, pos)
                  {hp, y, x, type}
                end)
                |> Enum.filter(fn {hp, _y, _x, _type} -> hp > 0 end)
                |> Enum.sort()
                |> Enum.find(& &1)

              if adjacent_enemy == nil do
                state
              else
                # attack!
                case adjacent_enemy do
                  {hp, y, x, type} when hp > 3 ->
                    Map.put(state, {x, y}, {type, hp - 3})

                  {hp, y, x, _type} when hp <= 3 ->
                    state = Map.delete(state, {x, y})

                    enemies_left =
                      Map.get(state, enemy_type)
                      |> MapSet.delete({x, y})

                    state = Map.put(state, enemy_type, enemies_left)

                    # TODO no enemies = game over
                    if MapSet.size(enemies_left) == 0 do
                      Map.put(state, :ended, true)
                      |> Map.put(:full_round, true)
                    else
                      state
                    end
                end
              end

            [] ->
              # we didn't move
              state
          end
        else
          # attack!
          case adjacent_enemy do
            {hp, y, x, type} when hp > 3 ->
              Map.put(state, {x, y}, {type, hp - 3})

            {hp, y, x, _type} when hp <= 3 ->
              state = Map.delete(state, {x, y})

              enemies_left =
                Map.get(state, enemy_type)
                |> MapSet.delete({x, y})

              state = Map.put(state, enemy_type, enemies_left)

              # TODO no enemies = game over
              if MapSet.size(enemies_left) == 0 do
                Map.put(state, :ended, true)
                |> Map.put(:full_round, true)
              else
                state
              end
          end
        end
    end
  end

  @doc """
  Find units next to a given position.
  """
  def find_adjacent_enemies(pos, enemy_positions) do
    get_surrounding_positions(pos)
    |> MapSet.intersection(enemy_positions)
  end

  @doc """
  Move a unit one step towards a goal.
  """
  def move_unit(from_pos, state, goals) do
    w = Map.get(state, :width)
    h = Map.get(state, :height)

    targets =
      goals
      |> Enum.reduce(MapSet.new(), fn pos, acc ->
        get_surrounding_positions(pos)
        |> Enum.reject(&out_of_bounds?(&1, w, h))
        |> Enum.reject(&is_occupied?(&1, state))
        |> Enum.into(MapSet.new())
        |> MapSet.union(acc)
      end)

    case expand(from_pos, state, targets) do
      :exhausted ->
        state

      :no_goals ->
        state

      {_x, _y} = to_pos ->
        {unit_type, _hp} = unit = Map.get(state, from_pos)
        unit_type_key = Map.get(@type_map, unit_type)

        unit_type_positions =
          Map.get(state, unit_type_key)
          |> MapSet.delete(from_pos)
          |> MapSet.put(to_pos)

        state
        |> Map.delete(from_pos)
        |> Map.put(to_pos, unit)
        |> Map.put(unit_type_key, unit_type_positions)
    end
  end

  @doc """
  """
  def expand({x, y}, state, goals) do
    if MapSet.size(goals) == 0 do
      :no_goals
    else
      open_nodes = %{} |> Map.put({x, y}, Day15Node.new(x, y))
      closed_nodes = %{}

      expand(open_nodes, state, goals, closed_nodes)
    end
  end

  defp expand(open_nodes, _, _, _) when is_map(open_nodes) and map_size(open_nodes) == 0,
    do: :exhausted

  defp expand(open_nodes, state, goals, closed_nodes) do
    # pick the best node
    node =
      open_nodes
      |> pick_best_node()

    %{x: x, y: y} = node

    # did we reach a goal?
    if MapSet.member?(goals, {x, y}) do
      first_node =
        node
        |> get_node_at_depth(1, closed_nodes)

      {first_node.x, first_node.y}
    else
      open_nodes = open_nodes |> Map.delete({x, y})
      closed_nodes = closed_nodes |> Map.put({x, y}, node)

      w = Map.get(state, :width)
      h = Map.get(state, :height)

      open_nodes =
        get_surrounding_positions(node)
        |> Enum.reject(&out_of_bounds?(&1, w, h))
        |> Enum.reject(&is_occupied?(&1, state))
        |> Enum.reject(&Map.get(open_nodes, &1))
        |> Enum.reject(&Map.get(closed_nodes, &1))
        |> Enum.reduce(open_nodes, fn {x, y}, open_nodes ->
          Map.put(open_nodes, {x, y}, Day15Node.new(x, y, node))
        end)

      expand(open_nodes, state, goals, closed_nodes)
    end
  end

  @doc """
  Select 4 coordinates around a given point.
  """
  def get_surrounding_positions(%{x: x, y: y}) do
    get_surrounding_positions({x, y})
  end

  def get_surrounding_positions({x, y}) do
    [{0, -1}, {1, 0}, {-1, 0}, {0, 1}]
    |> Enum.map(fn {x2, y2} -> {x + x2, y + y2} end)
    |> Enum.into(MapSet.new())
  end

  @doc """
  Select the "best" node from a list. Determined by depth, reading order, top down, left to right.
  """
  def pick_best_node(node_map) when is_map(node_map) do
    node_map
    |> Enum.map(fn {_k, v} -> v end)
    |> Enum.reduce(fn
      %{depth: d} = new_node, %{depth: pd} when d < pd -> new_node
      %{depth: d}, %{depth: pd} = prev_node when pd < d -> prev_node
      %{y: y} = new_node, %{y: py} when y < py -> new_node
      %{y: y}, %{y: py} = prev_node when py < y -> prev_node
      %{x: x} = new_node, %{x: px} when x < px -> new_node
      %{x: x}, %{x: px} = prev_node when px < x -> prev_node
      _, prev_node -> prev_node
    end)
  end

  @doc """
  Check if a coordinate is out of bounds.
  """
  def out_of_bounds?({x, y}, _width, _height) when x < 0 or y < 0, do: true
  def out_of_bounds?({x, y}, width, height) when x >= width or y >= height, do: true
  def out_of_bounds?(_, _, _), do: false

  @doc """
  Check if a coordinate is occupied.
  """
  def is_occupied?({x, y}, state) do
    Map.get(state, {x, y}) != nil
  end

  def get_node_at_depth(%Day15Node{} = n, d, visited_nodes) do
    if n.depth > d do
      get_node_at_depth(Map.get(visited_nodes, n.prev), 1, visited_nodes)
    else
      n
    end
  end

  def draw_map(state, round_number) do
    w = Map.get(state, :width)
    h = Map.get(state, :height)

    IO.puts("")
    IO.puts("Round #{round_number}")

    Enum.reduce(0..(h - 1), [], fn y, _lines ->
      {line, extra} =
        Enum.reduce(0..(w - 1), {"", []}, fn x, {line, extra} ->
          {char, extra} =
            case Map.get(state, {x, y}) do
              :wall -> {"#", extra}
              {:goblin, hp} -> {"G", ["G(#{hp})" | extra]}
              {:elf, hp} -> {"E", ["E(#{hp})" | extra]}
              _ -> {".", extra}
            end

          {line <> char, extra}
        end)

      extra_string =
        extra
        |> Enum.reverse()
        |> Enum.join(", ")

      IO.puts(line <> "    " <> extra_string)
    end)
  end
end
