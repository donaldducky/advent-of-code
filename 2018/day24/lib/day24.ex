defmodule Day24 do
  @moduledoc """
  Documentation for Day24.
  """

  def parse_input(lines) do
    {groups, _, _} =
      lines
      |> Enum.reduce({[], nil, 1}, fn
        "", acc ->
          acc

        line, {groups, _, next_id} when line == "Immune System:" ->
          {groups, :immune_system, next_id}

        line, {groups, _, next_id} when line == "Infection:" ->
          {groups, :infection, next_id}

        line, {groups, team, next_id} ->
          {:ok, tokens, _, _, _, _} = LineParser.line(line)

          group =
            tokens
            |> Enum.reduce(%{team: team}, fn
              {token, value}, acc when token == :weak or token == :immune ->
                Map.update(acc, token, [value], &[value | &1])

              {token, value}, acc ->
                Map.put(acc, token, value)
            end)
            |> Map.put(:id, next_id)

          {[group | groups], team, next_id + 1}
      end)

    groups
  end

  def do_battle(groups) do
    state =
      groups
      |> Enum.reduce(%{}, fn group, state ->
        %{id: id} = group
        Map.put(state, id, group)
      end)

    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(state, fn i, state ->
      before = state

      state =
        selection_phase(state)
        |> attack_phase(state)

      if battle_over?(state) do
        {:halt, state}
      else
        if i > 20000 do
          if before == state do
            IO.puts("state is the same")
          end

          state =
            state
            |> Enum.filter(fn {_, %{team: team}} -> team == :infection end)

          # consider it a loss
          # we hit a stalemate condition where both sides can't kill any units based on the rules
          {:halt, state}
        else
          {:cont, state}
        end
      end
    end)
  end

  def do_battle_until_reindeer_wins(groups) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while({nil, nil}, fn i, {loss, win} = acc ->
      boost =
        case acc do
          {nil, nil} -> 0
          {0, nil} -> 20
          {highest_loss, nil} -> highest_loss * highest_loss
          {nil, lowest_win} -> lowest_win / 2
          {highest_loss, lowest_win} -> div(lowest_win - highest_loss, 2) + highest_loss
        end

      {i, boost, acc} |> IO.inspect(label: "iteration")

      state = do_battle(groups |> boost(boost))

      {loss, win} =
        if reindeer_win?(state) do
          {loss, boost}
        else
          {boost, win}
        end

      if win != nil and loss != nil and win - loss == 1 do
        {:halt, state |> units_left()}
      else
        {:cont, {loss, win}}
      end
    end)
  end

  def boost(groups, boost_amount) do
    groups
    |> Enum.map(fn %{attack: attack, team: team} = group ->
      if team == :immune_system do
        Map.put(group, :attack, attack + boost_amount)
      else
        group
      end
    end)
  end

  def reindeer_win?(state) do
    if !battle_over?(state) do
      raise "battle is not over!"
    end

    state
    |> Enum.find(fn {_id, %{team: team}} -> team == :immune_system end)
    |> Kernel.!=(nil)
  end

  def battle_over?(state) do
    state
    |> Enum.group_by(fn {_id, %{team: team}} -> team end)
    |> Enum.count()
    |> Kernel.==(1)
  end

  def selection_phase(state) do
    selectable_groups_by_team =
      state
      |> Enum.reduce(%{}, fn {id, group}, acc ->
        %{team: team} = group

        Map.update(acc, team, Map.put(%{}, id, group), fn selectable ->
          Map.put(selectable, id, group)
        end)
      end)

    group_selection_order(state)
    |> select_targets(selectable_groups_by_team)
  end

  def attack_phase(targets, state) do
    group_attack_order(state)
    |> Enum.reduce(state, fn %{id: attacker_id}, state ->
      attacker = Map.get(state, attacker_id)
      defender_id = Map.get(targets, attacker_id)

      if attacker == nil or defender_id == nil do
        state
      else
        defender = Map.get(state, defender_id)
        %{hp: hp, units: units} = defender

        damage = calculate_damage(attacker, defender)

        units_lost = min(div(damage, hp), units)

        units_left = units - units_lost

        if units_left > 0 do
          defender = Map.put(defender, :units, units_left)
          Map.put(state, defender_id, defender)
        else
          Map.delete(state, defender_id)
        end
      end
    end)
  end

  def group_effective_power(%{units: units, attack: attack}) do
    units * attack
  end

  @doc """
  iex> Day24.group_attack_order(%{
  ...>   2 => %{units: 1, attack: 1, initiative: 2},
  ...>   1 => %{units: 1, attack: 1, initiative: 3},
  ...>   3 => %{units: 3, attack: 3, initiative: 1},
  ...> })
  [
    %{units: 1, attack: 1, initiative: 3},
    %{units: 1, attack: 1, initiative: 2},
    %{units: 3, attack: 3, initiative: 1},
  ]
  """
  def group_attack_order(state) do
    state
    |> Enum.map(fn {_, group} -> group end)
    |> Enum.sort_by(fn %{initiative: initiative} -> -initiative end)
  end

  @doc """
  iex> Day24.group_selection_order(%{
  ...>   1 => %{units: 1, attack: 1, initiative: 1},
  ...>   2 => %{units: 1, attack: 1, initiative: 2},
  ...>   3 => %{units: 3, attack: 3, initiative: 1},
  ...> })
  [
    %{units: 3, attack: 3, initiative: 1},
    %{units: 1, attack: 1, initiative: 2},
    %{units: 1, attack: 1, initiative: 1},
  ]
  """
  def group_selection_order(state) do
    state
    |> Enum.map(fn {_, group} -> group end)
    |> Enum.sort_by(fn %{initiative: initiative} = group ->
      {-group_effective_power(group), -initiative}
    end)
  end

  @doc """
  iex> Day24.select_targets([
  ...>   %{ attack: 116, attack_type: :bludgeoning, hp: 4706, id: 3, initiative: 1, team: :infection, units: 801, weak: [:radiation] },
  ...>   %{ attack: 4507, attack_type: :fire, hp: 5390, id: 1, initiative: 2, team: :immune_system, units: 17, weak: [:bludgeoning, :radiation] },
  ...>   %{ attack: 12, attack_type: :slashing, hp: 2961, id: 4, immune: [:radiation], initiative: 4, team: :infection, units: 4485, weak: [:cold, :fire] },
  ...>   %{ attack: 25, attack_type: :slashing, hp: 1274, id: 2, immune: [:fire], initiative: 3, team: :immune_system, units: 989, weak: [:slashing, :bludgeoning] },
  ...> ],
  ...> %{
  ...>   immune_system: %{
  ...>     1 => %{ attack: 4507, attack_type: :fire, hp: 5390, id: 1, initiative: 2, team: :immune_system, units: 17, weak: [:bludgeoning, :radiation] },
  ...>     2 => %{ attack: 25, attack_type: :slashing, hp: 1274, id: 2, immune: [:fire], initiative: 3, team: :immune_system, units: 989, weak: [:slashing, :bludgeoning] },
  ...>   },
  ...>   infection: %{
  ...>     3 => %{ attack: 116, attack_type: :bludgeoning, hp: 4706, id: 3, initiative: 1, team: :infection, units: 801, weak: [:radiation] },
  ...>     4 => %{ attack: 12, attack_type: :slashing, hp: 2961, id: 4, immune: [:radiation], initiative: 4, team: :infection, units: 4485, weak: [:cold, :fire] },
  ...>   },
  ...> })
  %{
    1 => 4,
    2 => 3,
    3 => 1,
    4 => 2,
  }
  """
  @enemy_team %{
    immune_system: :infection,
    infection: :immune_system
  }
  def select_targets(group_selection_order, selectable_groups_by_team) do
    {targets, _} =
      group_selection_order
      |> Enum.reduce({%{}, selectable_groups_by_team}, fn attacking_group,
                                                          {targets, selectable_groups_by_team} ->
        %{id: attacker_id, team: team} = attacking_group

        enemy_team = Map.get(@enemy_team, team)
        enemy_groups = Map.get(selectable_groups_by_team, enemy_team)
        target_id = select_target(attacking_group, enemy_groups)

        if target_id == nil do
          {Map.put(targets, attacker_id, nil), selectable_groups_by_team}
        else
          targets = Map.put(targets, attacker_id, target_id)

          selectable_groups_by_team =
            Map.put(selectable_groups_by_team, enemy_team, Map.delete(enemy_groups, target_id))

          {targets, selectable_groups_by_team}
        end
      end)

    targets
  end

  @doc """
  iex> Day24.select_target(
  ...>   %{ attack: 116, attack_type: :bludgeoning, hp: 4706, id: 3, initiative: 1, team: :infection, units: 801, weak: [:radiation] },
  ...>   %{
  ...>     1 => %{ attack: 4507, attack_type: :fire, hp: 5390, id: 1, initiative: 2, team: :immune_system, units: 17, weak: [:bludgeoning, :radiation] },
  ...>     2 => %{ attack: 25, attack_type: :slashing, hp: 1274, id: 2, immune: [:fire], initiative: 3, team: :immune_system, units: 989, weak: [:slashing] },
  ...>   }
  ...> )
  1

  iex> Day24.select_target(
  ...>   %{ attack: 116, attack_type: :bludgeoning, hp: 4706, id: 3, initiative: 1, team: :infection, units: 801, weak: [:radiation] },
  ...>   %{
  ...>     1 => %{ attack: 4507, attack_type: :fire, hp: 5390, id: 1, initiative: 2, team: :immune_system, units: 17, weak: [:bludgeoning, :radiation] },
  ...>     2 => %{ attack: 25, attack_type: :slashing, hp: 1274, id: 2, immune: [:fire], initiative: 3, team: :immune_system, units: 989, weak: [:slashing, :bludgeoning] },
  ...>   }
  ...> )
  1

  iex> Day24.select_target(
  ...>   %{ attack: 116, attack_type: :bludgeoning, hp: 4706, id: 3, initiative: 1, team: :infection, units: 801, weak: [:radiation] },
  ...>   %{
  ...>     1 => %{ attack: 25, attack_type: :fire, hp: 5390, id: 1, initiative: 2, team: :immune_system, units: 989, weak: [:bludgeoning, :radiation] },
  ...>     2 => %{ attack: 25, attack_type: :slashing, hp: 1274, id: 2, immune: [:fire], initiative: 3, team: :immune_system, units: 989, weak: [:slashing, :bludgeoning] },
  ...>   }
  ...> )
  2

  iex> Day24.select_target(
  ...>   %{ attack: 116, attack_type: :bludgeoning, hp: 4706, id: 3, initiative: 1, team: :infection, units: 801, weak: [:radiation] },
  ...>   %{
  ...>     1 => %{ attack: 25, attack_type: :fire, hp: 5390, id: 1, immune: [:bludgeoning], initiative: 2, team: :immune_system, units: 989, weak: [:radiation] },
  ...>     2 => %{ attack: 25, attack_type: :slashing, hp: 1274, id: 2, immune: [:fire, :bludgeoning], initiative: 3, team: :immune_system, units: 989, weak: [:slashing] },
  ...>   }
  ...> )
  nil
  """
  def select_target(group, enemy_groups) do
    possible_groups =
      enemy_groups
      |> Enum.map(fn {id, enemy_group} ->
        {id, enemy_group, calculate_damage(group, enemy_group)}
      end)
      |> Enum.reject(fn {_id, _enemy_group, damage} -> damage == 0 end)

    if Enum.find(possible_groups, & &1) == nil do
      nil
    else
      {target_id, _, _} =
        possible_groups
        |> Enum.max_by(fn {_id, enemy_group, damage} ->
          enemy_effective_power = group_effective_power(enemy_group)
          %{initiative: enemy_initiative} = enemy_group

          {damage, enemy_effective_power, enemy_initiative}
        end)

      target_id
    end
  end

  def calculate_damage(attacker, defender) do
    %{attack_type: attack_type} = attacker
    weaknesses = Map.get(defender, :weak, [])
    immunities = Map.get(defender, :immune, [])

    cond do
      attack_type in immunities -> 0
      attack_type in weaknesses -> 2 * group_effective_power(attacker)
      true -> group_effective_power(attacker)
    end
  end

  @doc """
  iex> Day24.units_left(%{
  ...>   1 => %{attack: 7, attack_type: :bludgeoning, hp: 3901, immune: [:radiation, :bludgeoning], initiative: 12, team: :immune_system, units: 4513, weak: [:slashing]},
  ...>   2 => %{attack: 19, attack_type: :radiation, hp: 8084, initiative: 11, team: :immune_system, units: 2991, weak: [:fire]},
  ...> })
  7504
  """
  def units_left(battle_result) do
    battle_result
    |> Enum.map(fn {_id, %{units: u}} -> u end)
    |> Enum.sum()
  end

  @doc """
  iex> Day24.first_half()
  16747
  """
  def first_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_input()
    |> do_battle()
    |> units_left()
  end

  @doc """
  iex> Day24.second_half()
  5923
  """
  def second_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_input()
    |> do_battle_until_reindeer_wins()
  end
end
