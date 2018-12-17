defmodule Day15Test do
  use ExUnit.Case
  doctest Day15
  import Day15

  test "parse_map" do
    map =
      """
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      """
      |> String.split("\n", trim: true)

    expected = %{
      {0, 0} => :wall,
      {1, 0} => :wall,
      {2, 0} => :wall,
      {3, 0} => :wall,
      {4, 0} => :wall,
      {5, 0} => :wall,
      {6, 0} => :wall,
      {0, 1} => :wall,
      {0, 2} => :wall,
      {0, 3} => :wall,
      {0, 4} => :wall,
      {0, 5} => :wall,
      {0, 6} => :wall,
      {1, 6} => :wall,
      {2, 6} => :wall,
      {3, 6} => :wall,
      {4, 6} => :wall,
      {5, 6} => :wall,
      {6, 1} => :wall,
      {6, 2} => :wall,
      {6, 3} => :wall,
      {6, 4} => :wall,
      {6, 5} => :wall,
      {6, 6} => :wall,
      {2, 3} => :wall,
      {4, 3} => :wall,
      {4, 4} => :wall,
      {2, 1} => {:goblin, 200, 1},
      {5, 2} => {:goblin, 200, 3},
      {5, 3} => {:goblin, 200, 4},
      {3, 4} => {:goblin, 200, 5},
      {4, 2} => {:elf, 200, 2},
      {5, 4} => {:elf, 200, 6},
      :goblins => MapSet.new([{2, 1}, {5, 2}, {5, 3}, {3, 4}]),
      :elves => MapSet.new([{4, 2}, {5, 4}]),
      :width => 7,
      :height => 7,
      :current_id => 7
    }

    assert parse_map(map) == expected
  end

  test "out_of_bounds?" do
    assert out_of_bounds?({-2, 5}, 10, 10) == true
    assert out_of_bounds?({2, -5}, 10, 10) == true
    assert out_of_bounds?({2, 10}, 10, 10) == true
    assert out_of_bounds?({10, 2}, 10, 10) == true
    assert out_of_bounds?({0, 0}, 10, 10) == false
    assert out_of_bounds?({0, 9}, 10, 10) == false
    assert out_of_bounds?({9, 0}, 10, 10) == false
  end

  test "is_occupied?" do
    assert is_occupied?({0, 0}, %{{0, 0} => :wall}) == true
    assert is_occupied?({0, 0}, %{{0, 0} => {:goblin, 200}}) == true
    assert is_occupied?({0, 0}, %{}) == false
  end

  test "pick_best_node" do
    assert pick_best_node(%{
             {1, 1} => Day15Node.new(1, 1),
             {1, 0} => Day15Node.new(1, 0, 3),
             {0, 0} => Day15Node.new(0, 0)
           }) == Day15Node.new(0, 0)

    assert pick_best_node(%{
             {1, 1} => Day15Node.new(1, 1),
             {1, 0} => Day15Node.new(1, 0),
             {1, 2} => Day15Node.new(1, 2)
           }) == Day15Node.new(1, 0)

    assert pick_best_node(%{
             {1, 0} => Day15Node.new(1, 0),
             {3, 0} => Day15Node.new(3, 0),
             {2, 0} => Day15Node.new(2, 0)
           }) == Day15Node.new(1, 0)

    assert pick_best_node(%{
             {2, 2} => Day15Node.new(2, 2),
             {3, 1} => Day15Node.new(3, 1)
           }) == Day15Node.new(3, 1)
  end

  test "get_surrounding_positions" do
    assert get_surrounding_positions(Day15Node.new(1, 1)) ==
             MapSet.new([{1, 0}, {0, 1}, {1, 2}, {2, 1}])
  end

  test "move_unit" do
    from = {2, 1}

    state = %{
      {2, 1} => {:elf, 200, 1},
      {4, 3} => {:goblin, 200, 2},
      :goblins => MapSet.new([{4, 3}]),
      :elves => MapSet.new([{2, 1}]),
      :width => 5,
      :height => 5
    }

    goals = MapSet.new([{4, 3}])

    expected = %{
      {3, 1} => {:elf, 200, 1},
      {4, 3} => {:goblin, 200, 2},
      :goblins => MapSet.new([{4, 3}]),
      :elves => MapSet.new([{3, 1}]),
      :width => 5,
      :height => 5
    }

    assert move_unit(from, state, goals) == {expected, {3, 1}}
  end

  test "find_adjacent_enemies" do
    position = {1, 1}
    enemy_positions = MapSet.new([{1, 0}, {1, 2}, {0, 1}, {2, 1}, {0, 0}, {2, 0}, {2, 2}, {0, 2}])

    assert find_adjacent_enemies(position, enemy_positions) ==
             MapSet.new([{1, 0}, {1, 2}, {0, 1}, {2, 1}])
  end

  test "perform_action unit moves to best spot" do
    unit_position = {2, 1}

    state = %{
      {2, 1} => {:elf, 200, 1},
      {4, 3} => {:goblin, 200, 2},
      :goblins => MapSet.new([{4, 3}]),
      :elves => MapSet.new([{2, 1}]),
      :width => 5,
      :height => 5,
      :actions_performed => MapSet.new()
    }

    expected = %{
      {3, 1} => {:elf, 200, 1},
      {4, 3} => {:goblin, 200, 2},
      :goblins => MapSet.new([{4, 3}]),
      :elves => MapSet.new([{3, 1}]),
      :width => 5,
      :height => 5,
      :actions_performed => MapSet.new([1])
    }

    assert perform_action(unit_position, state) == expected
  end

  test "perform_action attacks nearest unit" do
    unit_position = {2, 3}

    state = %{
      {2, 3} => {:elf, 200, 1},
      {3, 3} => {:goblin, 200, 2},
      :goblins => MapSet.new([{3, 3}]),
      :elves => MapSet.new([{2, 3}]),
      :width => 5,
      :height => 5,
      :actions_performed => MapSet.new()
    }

    expected = %{
      {2, 3} => {:elf, 200, 1},
      {3, 3} => {:goblin, 197, 2},
      :goblins => MapSet.new([{3, 3}]),
      :elves => MapSet.new([{2, 3}]),
      :width => 5,
      :height => 5,
      :actions_performed => MapSet.new([1])
    }

    assert perform_action(unit_position, state) == expected
  end

  test "calculate_turn_order" do
    state = %{
      :goblins => MapSet.new([{3, 1}, {5, 2}, {5, 3}, {3, 3}]),
      :elves => MapSet.new([{4, 2}, {5, 4}])
    }

    expected = [{3, 1}, {4, 2}, {5, 2}, {3, 3}, {5, 3}, {5, 4}]

    assert calculate_turn_order(state) == expected
  end

  test "combat_round" do
    state =
      """
      #######
      #.G...#
      #...EG#
      #.#.#G#
      #..G#E#
      #.....#
      #######
      """
      |> String.split("\n", trim: true)
      |> parse_map()

    expected =
      """
      #######
      #..G..#
      #...EG#
      #.#G#G#
      #...#E#
      #.....#
      #######
      """
      |> String.split("\n", trim: true)
      |> parse_map()
      |> Map.put(:actions_performed, MapSet.new([1, 2, 3, 4, 5, 6]))

    expected =
      [
        {5, 2, 197, 3},
        {5, 3, 197, 4},
        {4, 2, 197, 2},
        {5, 4, 197, 6},
        {3, 3, 200, 5}
      ]
      |> Enum.reduce(expected, fn {x, y, hp, id}, state ->
        {type, _prev_hp, _id} = Map.get(state, {x, y})
        Map.put(state, {x, y}, {type, hp, id})
      end)

    assert combat_round(state) == expected
  end

  test "combat_round last unit killed ends game" do
    state =
      """
      ####
      #GE#
      ####
      """
      |> String.split("\n", trim: true)
      |> parse_map()

    state =
      [
        {1, 1, 200},
        {2, 1, 3}
      ]
      |> Enum.reduce(state, fn {x, y, hp}, state ->
        {type, _prev_hp, id} = Map.get(state, {x, y})
        Map.put(state, {x, y}, {type, hp, id})
      end)

    new_state = combat_round(state)

    assert Map.get(new_state, {2, 1}) == nil
    assert {_type, 200, _id} = Map.get(new_state, {1, 1})
    assert Map.get(new_state, :ended)
  end

  test "combat_round unit should not double attack" do
    # G1 kills E1
    # G2 moves into E1's old spot and attacks E2
    # E1's turn comes and G2 is there, so it attacks again
    state =
      """
      ######
      #..G.#
      #.GEE#
      ######
      """
      |> String.split("\n", trim: true)
      |> parse_map()

    state =
      [
        {3, 2, 2}
      ]
      |> Enum.reduce(state, fn {x, y, hp}, state ->
        {type, _prev_hp, id} = Map.get(state, {x, y})
        Map.put(state, {x, y}, {type, hp, id})
      end)

    expected =
      """
      ######
      #..G.#
      #..GE#
      ######
      """
      |> String.split("\n", trim: true)
      |> parse_map()

    expected =
      [
        {4, 2, 197, 4},
        {3, 2, 197, 2}
      ]
      |> Enum.reduce(expected, fn {x, y, hp, id}, state ->
        {type, _prev_hp, _id} = Map.get(state, {x, y})
        Map.put(state, {x, y}, {type, hp, id})
      end)
      |> Map.put(:actions_performed, MapSet.new([1, 2, 4]))
      |> Map.put(:current_id, 5)

    assert combat_round(state) == expected
  end

  test "expand no valid locations" do
    state =
      """
      #######
      #.GE..#
      #.EE..#
      #######
      """
      |> String.split("\n", trim: true)
      |> parse_map()

    from = {2, 1}

    possible_locations = MapSet.new()

    assert expand(from, state, possible_locations) == :no_goals
  end

  test "expand" do
    state =
      """
      #######
      #.G...#
      #..E..#
      #######
      """
      |> String.split("\n", trim: true)
      |> parse_map()

    from = {2, 1}

    possible_locations = MapSet.new([{3, 1}, {2, 2}])

    assert expand(from, state, possible_locations) == {3, 1}
  end

  test "expand cannot find goal" do
    state =
      """
      #######
      #.G...#
      #..E..#
      #######
      """
      |> String.split("\n", trim: true)
      |> parse_map()

    from = {2, 1}

    possible_locations = MapSet.new([{10, 10}])

    assert expand(from, state, possible_locations) == :exhausted
  end

  test "combat_outcome" do
    map = """
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
    """

    assert combat_outcome(map) == 27730
  end

  test "combat_outcome 2" do
    map = """
    #######
    #G..#E#
    #E#E.E#
    #G.##.#
    #...#E#
    #...E.#
    #######
    """

    assert combat_outcome(map) == 36334
  end

  test "combat_outcome 3" do
    map = """
    #######
    #E..EG#
    #.#G.E#
    #E.##E#
    #G..#.#
    #..E#.#
    #######
    """

    assert combat_outcome(map) == 39514
  end

  test "combat_outcome 4" do
    map = """
    #######
    #E.G#.#
    #.#G..#
    #G.#.G#
    #G..#.#
    #...E.#
    #######
    """

    assert combat_outcome(map) == 27755
  end

  test "combat_outcome 5" do
    map = """
    #######
    #.E...#
    #.#..G#
    #.###.#
    #E#G#G#
    #...#G#
    #######
    """

    assert combat_outcome(map) == 28944
  end

  test "combat_outcome 6" do
    map = """
    #########
    #G......#
    #.E.#...#
    #..##..G#
    #...##..#
    #...#...#
    #.G...G.#
    #.....G.#
    #########
    """

    assert combat_outcome(map) == 18740
  end

  test "Day 1" do
    map = File.read!("input.txt")

    assert combat_outcome(map) == 226_688
  end
end
