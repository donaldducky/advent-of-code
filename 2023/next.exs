#!/usr/bin/env elixir

filename = fn day ->
  "#{System.get_env("PWD")}/day#{Integer.to_string(day) |> String.pad_leading(2, "0")}.livemd"
end

next = fn ->
  1..25
  |> Enum.reduce_while(nil, fn n, _acc ->
    if File.exists?(filename.(n)) do
      {:cont, nil}
    else
      {:halt, n}
    end
  end)
end

template = fn day ->
  """
  # Advent of Code 2023

  ```elixir
  Mix.install([
    {:req, "~> 0.3.2"}
  ])
  ```

  ## Day #{day}

  ```elixir
  input =
    "https://adventofcode.com/2023/day/#{day}/input"
    |> Req.get!(headers: [cookie: "session=\#{System.get_env("AOC_COOKIE")}"])
    |> Map.get(:body)
  ```

  ```elixir
  sample = \"""
  \"""
  ```

  ```elixir
  defmodule A do
    def parse(input) do
      input
      |> String.split("\\n", trim: true)
    end

    def part1(input) do
      input
      |> parse()
    end

    def part2(input) do
      input
      |> parse()
    end
  end
  ```

  ## Part 1

  <!-- livebook:{"reevaluate_automatically":true} -->

  ```elixir
  input
  |> A.part1()
  ```

  <!-- livebook:{"reevaluate_automatically":true} -->

  ## Part 2

  ```elixir
  input
  |> A.part2()
  ```
  """
end

case next.() do
  nil ->
    IO.puts("All done!")

  n ->
    f = filename.(n)
    IO.write("Writing #{f}...")
    File.write!(f, template.(n))
    IO.puts("✅")

    q = %{
      url: "file://#{f}"
    }

    System.cmd("open", ["http://localhost:8080/import?#{URI.encode_query(q)}"])
end
