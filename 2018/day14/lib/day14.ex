defmodule Day14 do
  @moduledoc """
  Documentation for Day14.
  """

  @doc """
  ## Examples

      iex> Day14.next_10(9)
      "5158916779"

      iex> Day14.next_10(5)
      "0124515891"

      iex> Day14.next_10(18)
      "9251071085"

      iex> Day14.next_10(2018)
      "5941429882"

  """
  def next_10(num_recipes) do
    elves = [0, 1]

    {scores, count} =
      [3, 7]
      |> Enum.reduce({%{}, 0}, fn score, {scores, i} ->
        {Map.put(scores, i, score), i + 1}
      end)

    next_n = 10

    max_count =
      (num_recipes + next_n)
      |> IO.inspect(label: "max")

    scores = create_recipes(elves, scores, count, max_count)

    (max_count - 1)..(max_count - next_n)
    |> Enum.reduce([], fn i, acc -> [Map.get(scores, i) | acc] end)
    |> Enum.join()
  end

  def create_recipes(elves, scores, count, max_count) do
    # elves |> IO.inspect(label: "elves")
    # scores |> IO.inspect(label: "scores")
    # count |> IO.inspect(label: "count")

    {scores, count} =
      elves
      |> Enum.reduce(0, fn i, sum -> sum + (scores |> Map.get(i)) end)
      |> Integer.digits()
      # |> IO.inspect(label: "new digits")
      |> Enum.reduce({scores, count}, fn score, {scores, i} ->
        {Map.put(scores, i, score), i + 1}
      end)

    elves =
      elves
      |> Enum.map(fn i ->
        s = Map.get(scores, i)
        rem(s + 1 + i, count)
      end)

    # IO.puts("")

    if count < max_count do
      create_recipes(elves, scores, count, max_count)
    else
      scores
    end
  end

  def first_half() do
    next_10(890_691)
  end
end
