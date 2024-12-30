defmodule AocHelpers do
  @moduledoc """
  Documentation for `AocHelpers`.
  """

  def download_puzzle(year, day, opts) when is_integer(year) and is_integer(day) do
    cookie = Keyword.fetch!(opts, :cookie)

    "https://adventofcode.com/#{year}/day/#{day}/input"
    |> Req.get!(headers: [cookie: "session=#{cookie}"])
    |> Map.get(:body)
  end

  def blocks(input) do
    String.split(input, "\n\n", trim: true)
  end

  def lines(input) do
    String.split(input, "\n", trim: true)
  end

  def map_ints(lines), do: lines |> Enum.map(&String.to_integer/1)
end
