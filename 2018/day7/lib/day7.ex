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
      {"CABDFE", 21}

      iex> Day7.step_order([
      ...> {?C, ?A},
      ...> {?C, ?F},
      ...> {?A, ?B},
      ...> {?A, ?D},
      ...> {?B, ?E},
      ...> {?D, ?E},
      ...> {?F, ?E},
      ...> ], 2, 0)
      {"CABFDE", 15}

  """
  def step_order(input), do: step_order(input, 1, 0)

  def step_order(input, worker_count, work_seconds_base) do
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

    state = %{
      step_order: [],
      deps_map: deps_map,
      next_map: next_map,
      candidates: candidates,
      workers: [],
      total_work_time: 0
    }

    all_letters
    |> Enum.reduce(state, fn
      _letter,
      %{
        step_order: step_order,
        deps_map: deps_map,
        candidates: candidates,
        total_work_time: total_work_time
      }
      when map_size(deps_map) == 0 ->
        next =
          candidates
          |> Enum.min()

        steps =
          [next | step_order]
          |> Enum.reverse()
          |> String.Chars.to_string()

        total_work_time = total_work_time + work_seconds_base + next - 64

        {steps, total_work_time}

      _letter,
      %{
        step_order: step_order,
        deps_map: deps_map,
        next_map: next_map,
        candidates: candidates,
        workers: workers,
        total_work_time: total_work_time
      } = acc ->
        filtered_candidates =
          candidates
          |> Enum.filter(fn a -> !Map.has_key?(next_map, a) end)

        {workers, candidates} =
          filtered_candidates
          |> Enum.reduce_while({workers, candidates}, fn
            _, {workers, candidates} when length(workers) == worker_count ->
              {:halt, {workers, candidates}}

            letter, {workers, candidates} ->
              # letter should be something like ?A == 65, we subtract 64 to set A..Z to 1..26
              work_time = work_seconds_base + letter - 64

              candidates =
                candidates
                |> Enum.reject(&(&1 == letter))

              {:cont, {[{letter, work_time} | workers], candidates}}
          end)

        {next, last_ttl} =
          workers
          |> Enum.min_by(fn {_, ttl} -> ttl end)

        total_work_time = total_work_time + last_ttl

        workers =
          workers
          |> Enum.reject(fn {letter, _ttl} -> letter == next end)
          |> Enum.map(fn {letter, ttl} -> {letter, ttl - last_ttl} end)

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
          next_letters
          |> Enum.into(candidates)
          |> Enum.sort()
          |> Enum.uniq()

        deps_map = Map.delete(deps_map, next)

        acc
        |> Map.put(:deps_map, deps_map)
        |> Map.put(:next_map, next_map)
        |> Map.put(:candidates, candidates)
        |> Map.put(:step_order, [next | step_order])
        |> Map.put(:workers, workers)
        |> Map.put(:total_work_time, total_work_time)
    end)
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
    |> elem(0)
  end

  def second_half() do
    read_input()
    |> step_order(5, 60)
    |> elem(1)
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
