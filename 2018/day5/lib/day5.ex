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
    'abcdefghijklmnopqrstuvwxyz'
    |> Enum.map(&[&1, &1 - 32])
    |> Enum.map(&String.Chars.to_string/1)
    |> Enum.map(fn chars_to_remove ->
      ("[" <> chars_to_remove <> "]")
      |> Regex.compile()
      |> elem(1)
    end)
    |> Enum.map(&String.replace(string, &1, ""))
    |> Enum.filter(&(&1 != string))
    |> Enum.map(&reaction/1)
    |> Enum.map(&String.length/1)
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
