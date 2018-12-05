defmodule Day5 do
  @moduledoc """
  Documentation for Day5.
  """

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
    regex =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      |> Enum.reduce([], fn
        char, acc ->
          [[char + 32, char] | [[char, char + 32] | acc]]
      end)
      |> Enum.map(&String.Chars.to_string/1)
      |> Enum.join("|")
      |> Regex.compile()
      |> elem(1)

    replace(string, regex)
  end

  def replace(string, regex) do
    new_string =
      string
      |> String.replace(regex, "")

    if new_string != string do
      replace(new_string, regex)
    else
      string
    end
  end
end

File.read!("input.txt")
|> String.trim()
|> Day5.reaction()
|> String.length()
|> IO.puts()
