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
    input
    |> String.trim()
    |> String.split("\n\n", trim: true)
  end

  def lines(input) do
    String.split(input, "\n", trim: true)
  end

  def map_ints(lines), do: lines |> Enum.map(&String.to_integer/1)

  def grid(input) do
    lines =
      lines(input)
      |> Enum.map(&String.split(&1, "", trim: true))

    h = lines |> Enum.count()
    w = hd(lines) |> Enum.count()

    grid =
      for {row, y} <- Enum.with_index(lines),
          {cell, x} <- Enum.with_index(row),
          into: %{},
          do: {{x, y}, cell}

    {grid, w, h}
  end

  def find_pos(grid, val) do
    grid
    |> Enum.find(fn {_, v} -> v == val end)
    |> case do
      nil -> nil
      {pos, _} -> pos
    end
  end

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

  def neighbours({x, y}, n) when n > 0 do
    for dx <- -n..n, dy <- -n..n, abs(dx) + abs(dy) <= n, {dx, dy} != {0, 0}, do: {x + dx, y + dy}
  end

  def manhattan_dist({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)
end
