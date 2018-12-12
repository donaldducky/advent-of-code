defmodule Day12 do
  @moduledoc """
  Documentation for Day12.
  """

  @doc """
  Sum pots after 20 iterations.
  """
  def sum_pots(input) do
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

    1..20
    |> Enum.reduce(initial_state, fn _generation, state ->
      step(state, rules)
    end)
    |> Enum.sum()
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
        if Map.get(rules, current_string) == "#" do
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
      |> Enum.reduce(%{}, fn [key, pot_state], acc -> Map.put(acc, key, pot_state) end)

    {initial_state, rules}
  end

  def first_half() do
    read_input()
    |> sum_pots()
  end

  def read_input() do
    File.read!("input.txt")
    |> String.trim()
    |> String.split("\n")
  end
end
