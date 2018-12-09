defmodule Day7 do
  @moduledoc """
  Documentation for Day7.
  """

  @doc """
  Calculate steps in order, preferring the letter higher in the alphabet.

  ## Examples

      iex> Day7.step_order([
      ...> {?C, ?A},
      ...> {?C, ?F},
      ...> {?A, ?B},
      ...> {?A, ?D},
      ...> {?B, ?E},
      ...> {?D, ?E},
      ...> {?F, ?E},
      ...> ])
      "CABDFE"

  """
  def step_order(input) do
    all_letters =
      input
      |> Enum.reduce(MapSet.new(), fn {a, b}, acc ->
        acc
        |> MapSet.put(a)
        |> MapSet.put(b)
      end)

    deps_map =
      input
      |> Enum.reduce(%{}, fn {a, b}, acc ->
        acc |> Map.update(a, MapSet.new([b]), &MapSet.put(&1, b))
      end)

    next_map =
      input
      |> Enum.reduce(%{}, fn {a, b}, acc ->
        acc |> Map.update(b, MapSet.new([a]), &MapSet.put(&1, a))
      end)

    candidates =
      all_letters
      |> Enum.filter(fn a -> !Map.has_key?(next_map, a) end)

    next =
      candidates
      |> Enum.min()

    next_letters =
      deps_map
      |> Map.get(next)

    next_map =
      next_letters
      |> Enum.reduce(next_map, fn a, acc ->
        # remove next letter from each of the dependencies
        deps =
          Map.get(acc, a)
          |> MapSet.delete(next)

        if MapSet.size(deps) == 0 do
          Map.delete(acc, a)
        else
          Map.put(acc, a, deps)
        end
      end)

    candidates =
      candidates
      |> Enum.reject(fn a -> a == next end)

    candidates =
      Map.get(deps_map, next)
      |> Enum.reduce(candidates, fn a, acc -> [a | acc] end)
      |> Enum.sort()

    deps_map = Map.delete(deps_map, next)

    step([next], deps_map, next_map, candidates)
  end

  def step(acc) do
    acc
    |> Enum.reverse()
    |> String.Chars.to_string()
  end

  def step(acc, deps_map, next_map, candidates)
      when map_size(deps_map) == 0 and map_size(next_map) == 0 do
    step([candidates |> Enum.take(1) | acc])
  end

  def step(acc, deps_map, next_map, candidates) do
    filtered_candidates =
      candidates
      |> Enum.filter(fn a -> !Map.has_key?(next_map, a) end)

    next =
      filtered_candidates
      |> Enum.min()

    next_letters =
      deps_map
      |> Map.get(next)

    next_map =
      next_letters
      |> Enum.reduce(next_map, fn a, acc ->
        # remove next letter from each of the dependencies
        deps =
          Map.get(acc, a)
          |> MapSet.delete(next)

        if MapSet.size(deps) == 0 do
          Map.delete(acc, a)
        else
          Map.put(acc, a, deps)
        end
      end)

    candidates =
      candidates
      |> Enum.reject(fn a -> a == next end)

    candidates =
      Map.get(deps_map, next)
      |> Enum.reduce(candidates, fn a, acc -> [a | acc] end)
      |> Enum.uniq()
      |> Enum.sort()

    deps_map = Map.delete(deps_map, next)

    step([next | acc], deps_map, next_map, candidates)
  end

  @doc """
  First half of exercise

  ## Examples

      iex> Day7.first_half()
      "BCADPVTJFZNRWXHEKSQLUYGMIO"

  """
  def first_half() do
    read_input()
    |> step_order()
  end

  @spec read_input() :: Enumerable.t()
  def read_input() do
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Stream.map(&LineParser.dependency_node/1)
    |> Stream.map(fn {:ok, [dep, node], _, _, _, _} -> {dep, node} end)
  end
end

defmodule LineParser do
  import NimbleParsec

  # "Step C must be finished before step A can begin."
  dependency_node =
    ignore(string("Step "))
    |> ascii_char([])
    |> ignore(string(" must be finished before step "))
    |> ascii_char([])
    |> ignore(string(" can begin."))

  defparsec(:dependency_node, dependency_node)
end
