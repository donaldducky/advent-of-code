defmodule Day6 do
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      import Day6

      test "" do
      end
    end

  [] ->
    File.stream!("input.txt")
    |> Stream.map(&String.trim/1)
    |> Day6.guard_duty_product()
    |> IO.puts()

  ["-2"] ->
    IO.puts("not implemented")

  _ ->
    IO.puts("""
    Usage:
      elixir day6.exs --test
      elixir day6.exs
      elixir day6.exs -2
    """)
end
