defmodule Day4 do
  def guard_duty_product(lines) do
    %{guard_minutes: guard_minutes} =
      lines
      |> Enum.sort()
      |> Enum.map(&parse_line/1)
      |> Enum.reduce(%{current_guard: nil, sleep_time: 0, guard_minutes: %{}}, fn
        {_y, _m, _d, _h, slept_at, "falls asleep"}, acc ->
          Map.put(acc, :sleep_time, slept_at)

        {_y, _m, _d, _h, woke_at, "wakes up"},
        %{current_guard: guard_id, sleep_time: slept_at, guard_minutes: guard_minutes} = acc ->
          minutes_asleep = Enum.to_list(slept_at..(woke_at - 1))

          guard_minutes =
            Map.update(guard_minutes, guard_id, minutes_asleep, fn minutes ->
              Enum.concat(minutes, minutes_asleep)
            end)

          %{acc | guard_minutes: guard_minutes}

        {_y, _m, _d, _h, _i, text}, acc ->
          [_all, guard_id] = Regex.run(~r/Guard #(\d+) begins shift/, text)
          Map.put(acc, :current_guard, Integer.parse(guard_id) |> elem(0))
      end)

    most_minutes_guard =
      guard_minutes
      |> Enum.max_by(fn {_k, v} ->
        v |> Enum.count()
      end)

    {guard_id, minutes_slept} = most_minutes_guard

    most_slept_minute =
      minutes_slept
      |> Enum.group_by(& &1)
      |> Enum.max_by(fn {_k, v} -> Enum.count(v) end)
      |> elem(0)

    guard_id * most_slept_minute
  end

  defp parse_line(line) do
    [_all, y, m, d, h, i, text] =
      Regex.run(~r/\[(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})\] (.*)/, line)

    {y, m, d, h, Integer.parse(i) |> elem(0), text}
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day4Test do
      use ExUnit.Case

      import Day4

      test "product" do
        {:ok, io} =
          StringIO.open("""
          [1518-11-01 00:00] Guard #10 begins shift
          [1518-11-01 00:05] falls asleep
          [1518-11-01 00:25] wakes up
          [1518-11-01 00:30] falls asleep
          [1518-11-01 00:55] wakes up
          [1518-11-01 23:58] Guard #99 begins shift
          [1518-11-02 00:40] falls asleep
          [1518-11-02 00:50] wakes up
          [1518-11-03 00:05] Guard #10 begins shift
          [1518-11-03 00:24] falls asleep
          [1518-11-03 00:29] wakes up
          [1518-11-04 00:02] Guard #99 begins shift
          [1518-11-04 00:36] falls asleep
          [1518-11-04 00:46] wakes up
          [1518-11-05 00:03] Guard #99 begins shift
          [1518-11-05 00:45] falls asleep
          [1518-11-05 00:55] wakes up
          """)

        assert guard_duty_product(io |> IO.stream(:line) |> Stream.map(&String.trim/1)) == 240
      end
    end

  [input_file] ->
    File.stream!(input_file)
    |> Stream.map(&String.trim/1)
    |> Day4.guard_duty_product()
    |> IO.puts()

  [_input_file, "-2"] ->
    IO.puts("Not implemented")

  _ ->
    IO.puts("""
    Usage:
      elixir day4.exs --test
      elixir day4.exs input_file
      elixir day4.exs input_file -2
    """)
end
