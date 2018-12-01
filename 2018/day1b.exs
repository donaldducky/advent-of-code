# elixir day1b.exs < day1-input.txt
defmodule Day1b do
  def first_frequency_twice(list_of_ints) do
    first_frequency_twice(0, list_of_ints, %{}, list_of_ints)
  end

  def first_frequency_twice(current_frequency, [hd | tl], acc, initial_list) do
    acc = Map.put(acc, current_frequency, true)
    f = current_frequency + hd

    if Map.has_key?(acc, f) do
      f
    else
      first_frequency_twice(f, tl, acc, initial_list)
    end
  end

  def first_frequency_twice(current_frequency, [], acc, initial_list) do
    first_frequency_twice(current_frequency, initial_list, acc, initial_list)
  end
end

ExUnit.start()

defmodule Day1bTest do
  use ExUnit.Case

  import Day1b

  test "first_twice" do
    assert first_frequency_twice([+1, -1]) == 0
    assert first_frequency_twice([+3, +3, +4, -2, -4]) == 10
    assert first_frequency_twice([-6, +3, +8, +5, -6]) == 5
    assert first_frequency_twice([+7, +7, -2, -7, -4]) == 14
  end
end

IO.stream(:stdio, :line)
|> Stream.map(&String.trim(&1))
|> Stream.map(&Integer.parse(&1))
|> Stream.map(&Kernel.elem(&1, 0))
|> Enum.to_list()
|> Day1b.first_frequency_twice()
|> IO.puts()
