defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """

  @offset ?a - ?A
  defguard is_upcase_and_downcase(a, b) when abs(a - b) == @offset

  @doc """
  React

  ## Examples

      iex> Day5.reaction("aA")
      ""
      iex> Day5.reaction("abBA")
      ""
      iex> Day5.reaction("aabAAB")
      "aabAAB"
      iex> Day5.reaction("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"

  """
  def reaction(string) when is_binary(string) do
    string
    |> String.to_charlist()
    |> reaction()
  end

  def reaction(charlist) when is_list(charlist) do
    charlist
    |> Enum.reduce([], fn
      c, [] ->
        [c]

      c, [head | tail] when is_upcase_and_downcase(c, head) ->
        tail

      c, acc ->
        [c | acc]
    end)
    |> String.Chars.to_string()
    |> String.reverse()
  end

  @doc """
  React improved

  ## Examples

      iex> Day5.improved_reaction("dabAcCaCBAcCcaDA")
      4

  """
  def improved_reaction(string) do
    ?a..?z
    |> Enum.map(fn c ->
      string
      |> String.to_charlist()
      |> Enum.filter(fn c2 ->
        c2 != c && c2 != c - @offset
      end)
      |> reaction()
      |> String.length()
    end)
    |> Enum.min()
  end
end

File.read!("input.txt")
|> String.trim()
|> Day5.reaction()
|> String.length()
|> IO.puts()

File.read!("input.txt")
|> String.trim()
|> Day5.improved_reaction()
|> IO.puts()
