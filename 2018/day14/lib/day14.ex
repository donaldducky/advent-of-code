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

    max_count = num_recipes + next_n

    scores = create_recipes(elves, scores, count, max_count)

    (max_count - 1)..(max_count - next_n)
    |> Enum.reduce([], fn i, acc -> [Map.get(scores, i) | acc] end)
    |> Enum.join()
  end

  @doc """
  ## Examples

  #iex> Day14.appears_after("51589")
  #9

  iex> Day14.appears_after("01245")
  5

  #iex> Day14.appears_after("92510")
  #18

  #iex> Day14.appears_after("59414")
  #2018
  """
  def appears_after(pattern) do
    elves = [0, 1]

    n = pattern |> String.length()

    m = Matcher.new(pattern)

    {scores, count, matcher} =
      [3, 7]
      |> Enum.reduce({%{}, 0, m}, fn score, {scores, i, matcher} ->
        matcher = Matcher.next(matcher, Integer.to_string(score))

        {Map.put(scores, i, score), i + 1, matcher}
      end)

    create_recipes_pattern(elves, scores, count, n, matcher)
  end

  def create_recipes(elves, scores, count, max_count) do
    {scores, count} =
      elves
      |> Enum.reduce(0, fn i, sum -> sum + (scores |> Map.get(i)) end)
      |> Integer.digits()
      |> Enum.reduce({scores, count}, fn score, {scores, i} ->
        {Map.put(scores, i, score), i + 1}
      end)

    elves =
      elves
      |> Enum.map(fn i ->
        s = Map.get(scores, i)
        rem(s + 1 + i, count)
      end)

    if count < max_count do
      create_recipes(elves, scores, count, max_count)
    else
      scores
    end
  end

  def create_recipes_pattern(elves, scores, count, n, matcher) do
    {scores, count, matcher, found} =
      elves
      |> Enum.reduce(0, fn i, sum -> sum + (scores |> Map.get(i)) end)
      |> Integer.digits()
      |> Enum.reduce({scores, count, matcher, 0}, fn
        score, {scores, i, matcher, 0} ->
          matcher = Matcher.next(matcher, Integer.to_string(score))

          found =
            if Matcher.fully_matched?(matcher) do
              i + 1 - n
            else
              0
            end

          {Map.put(scores, i, score), i + 1, matcher, found}

        _score, {scores, i, matcher, found} ->
          {scores, i, matcher, found}
      end)

    elves =
      elves
      |> Enum.map(fn i ->
        s = Map.get(scores, i)
        rem(s + 1 + i, count)
      end)

    if found > 0 do
      found
    else
      create_recipes_pattern(elves, scores, count, n, matcher)
    end
  end

  def first_half() do
    next_10(890_691)
  end

  def second_half() do
    appears_after("890691")
  end
end

defmodule Matcher do
  def new(pattern) do
    pattern = pattern |> String.codepoints()
    [pattern, [], pattern]
  end

  def next([[next_val | rest], matches, pattern], val) do
    if val == next_val do
      [rest, [next_val | matches], pattern]
    else
      # no match, reset
      [next_match | rest] = pattern

      if next_match == val do
        [rest, [next_match], pattern]
      else
        [pattern, [], pattern]
      end
    end
  end

  def fully_matched?([[], _, _]), do: true
  def fully_matched?(_), do: false
end
