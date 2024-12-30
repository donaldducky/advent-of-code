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

  def draw_grid(grid, w, h) do
    for y <- 0..(h - 1), x <- 0..(w - 1), reduce: "" do
      acc ->
        (acc <> Map.get(grid, {x, y}, "."))
        |> then(fn acc ->
          case {x, y} do
            {x, y} when x == w - 1 and y < h - 1 ->
              acc <> "\n"

            _ ->
              acc
          end
        end)
    end
  end

  def code_block(text) do
    [
      "```",
      text,
      "```"
    ]
    |> Enum.join("\n")
  end

  def neighbours(), do: [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
  def neighbours({x, y}), do: neighbours() |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)

  def manhattan_dist({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
end
