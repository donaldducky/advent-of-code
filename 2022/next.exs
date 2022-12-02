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
  # Advent of Code 2022

  ```elixir
  Mix.install([
    {:req, "~> 0.3.2"}
  ])
  ```

  ## Day #{day}

  ```elixir
  input =
    "https://adventofcode.com/2022/day/#{day}/input"
    |> Req.get!(headers: [cookie: "session=\#{System.get_env("AOC_COOKIE")}"])
    |> Map.get(:body)
  ```

  ## Part 1

  ```elixir
  input
  ```

  ## Part 2

  ```elixir

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
end
