# Usage: elixir day1b.exs day1-input.txt
System.argv()
|> hd()
|> File.stream!()
|> Stream.cycle()
|> Stream.map(&String.trim(&1))
|> Stream.map(&Integer.parse(&1))
|> Stream.map(&Kernel.elem(&1, 0))
|> Enum.reduce_while(%{current: 0, seen: %{}}, fn x, %{current: current, seen: seen} = acc ->
  next = current + x
  acc = %{acc | current: next, seen: seen |> Map.put(current, true)}

  if Map.has_key?(seen, next) do
    {:halt, next}
  else
    {:cont, acc}
  end
end)
|> IO.puts()
