# Usage: elixir day1b.exs day1-input.txt
System.argv()
|> hd()
|> File.stream!()
|> Stream.cycle()
|> Stream.map(&String.trim(&1))
|> Stream.map(&Integer.parse(&1))
|> Stream.map(&Kernel.elem(&1, 0))
|> Enum.reduce_while({0, MapSet.new([0])}, fn x, {current, seen} ->
  next = current + x

  if next in seen do
    {:halt, next}
  else
    {:cont, {next, MapSet.put(seen, next)}}
  end
end)
|> IO.puts()
