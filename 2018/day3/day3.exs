defmodule Day3 do
  def multiple_claims_count(claims) do
    claims
    |> Stream.map(&parse_lines/1)
    |> map_claims()
    |> Enum.count(fn {_, n} -> n > 1 end)
  end

  def intact_claim(claims) do
    all_claims =
      claims
      |> Stream.map(&parse_lines/1)
      |> Enum.to_list()

    mapped_claims =
      all_claims
      |> map_claims()

    all_claims
    |> Enum.find(fn [_, x, y, w, h] ->
      for(x2 <- x..(x + w - 1), y2 <- y..(y + h - 1), do: {x2, y2})
      |> Enum.reduce_while(true, fn pair, true ->
        if Map.get(mapped_claims, pair) == 1 do
          {:cont, true}
        else
          {:halt, false}
        end
      end)
    end)
    |> Enum.at(0)
  end

  defp parse_lines(line) do
    [_all, n, x, y, w, h] = Regex.run(~r/^# ?(\d+) @ (\d+),(\d+): (\d+)x(\d+)$/, line)

    [n, x, y, w, h]
    |> Enum.map(&Integer.parse/1)
    |> Enum.map(&Kernel.elem(&1, 0))
  end

  defp map_claims(parsed_lines) do
    parsed_lines
    |> Enum.reduce(%{}, fn [_n, x, y, w, h], acc ->
      for(x2 <- x..(x + w - 1), y2 <- y..(y + h - 1), do: {x2, y2})
      |> Enum.reduce(acc, fn pair, acc ->
        Map.update(acc, pair, 1, &(&1 + 1))
      end)
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day3Test do
      use ExUnit.Case

      import Day3

      test "multiple_claims_count" do
        {:ok, io} =
          StringIO.open("""
          #1 @ 1,3: 4x4
          #2 @ 3,1: 4x4
          #3 @ 5,5: 2x2
          """)

        assert multiple_claims_count(io |> IO.stream(:line) |> Stream.map(&String.trim/1)) == 4
      end

      test "intact_claim" do
        {:ok, io} =
          StringIO.open("""
          #1 @ 1,3: 4x4
          #2 @ 3,1: 4x4
          #3 @ 5,5: 2x2
          """)

        assert intact_claim(io |> IO.stream(:line) |> Stream.map(&String.trim/1)) == 3
      end
    end

  [input_file] ->
    File.stream!(input_file)
    |> Stream.map(&String.trim/1)
    |> Day3.multiple_claims_count()
    |> IO.puts()

  [input_file, "-2"] ->
    File.stream!(input_file)
    |> Stream.map(&String.trim/1)
    |> Day3.intact_claim()
    |> IO.puts()

  _ ->
    IO.puts("""
    Usage:
      elixir day3.exs --test
      elixir day3.exs input_file
      elixir day3.exs input_file -2
    """)
end
