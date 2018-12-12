defmodule Day12 do
  @moduledoc """
  Documentation for Day12.
  """

  @doc """
  Sum pots after 20 iterations.
  """
  def sum_pots(input) do
    sum_pots(input, 20)
  end

  def sum_pots(input, generations) do
    {initial_state, rules} =
      input
      |> parse()

    initial_state =
      initial_state
      |> String.codepoints()
      |> Enum.with_index()
      |> Enum.filter(fn {a, _i} -> a == "#" end)
      |> Enum.map(fn {_a, i} -> i end)
      |> Enum.into(MapSet.new())

    {_end_state, generation, sum, {diff_value, _diff_count}} =
      1..generations
      |> Enum.reduce_while({initial_state, 0, 0, {0, 0}}, fn generation,
                                                             {state, _generation, prev_sum,
                                                              {prev_diff, diff_count}} ->
        s = step(state, rules)
        sum = s |> Enum.sum()
        diff = sum - prev_sum

        {prev_diff, diff_count} =
          if diff != prev_diff do
            {diff, 1}
          else
            {prev_diff, diff_count + 1}
          end

        if diff_count > 10 do
          {:halt, {s, generation, sum, {prev_diff, diff_count}}}
        else
          {:cont, {s, generation, sum, {prev_diff, diff_count}}}
        end
      end)

    if generations == generation do
      sum
    else
      sum + (generations - generation) * diff_value
    end
  end

  def step(state, rules) do
    {min, max} = state |> Enum.min_max()

    current_string =
      (min - 2)..(min - 1)
      |> Enum.reduce("..", fn i, acc ->
        acc <> plant_char(MapSet.member?(state, i))
      end)

    (min - 2)..(max + 2)
    |> Enum.reduce({MapSet.new(), current_string}, fn i, {new_state, current_string} ->
      current_string = current_string <> plant_char(MapSet.member?(state, i + 2))

      <<_::utf8, next_string::binary>> = current_string

      new_state =
        if MapSet.member?(rules, current_string) do
          new_state |> MapSet.put(i)
        else
          new_state |> MapSet.delete(i)
        end

      {new_state, next_string}
    end)
    |> elem(0)
  end

  def plant_char(true), do: "#"
  def plant_char(false), do: "."

  def parse(input) do
    {[<<"initial state: ", initial_state::binary>>], rules} =
      input
      |> Enum.split(1)

    rules =
      rules
      |> Enum.drop(1)
      |> Enum.map(&String.split(&1, " => "))
      |> Enum.filter(fn [_a, b] -> b == "#" end)
      |> Enum.map(fn [a, _b] -> a end)
      |> Enum.into(MapSet.new())

    {initial_state, rules}
  end

  def first_half() do
    read_input()
    |> sum_pots()
  end

  def second_half() do
    read_input()
    |> sum_pots(50_000_000_000)
  end

  def read_input() do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
  end
end
