# elixir day1.exs < day1-input.txt
IO.stream(:stdio, :line)
|> Stream.map(&String.trim(&1))
|> Stream.map(&Integer.parse(&1))
|> Stream.map(&Kernel.elem(&1, 0))
|> Enum.sum()
|> IO.puts()
