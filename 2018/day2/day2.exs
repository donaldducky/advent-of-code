defmodule Day2 do
  def checksum(ids) do
    [twos, threes] =
      ids
      |> Stream.map(&id_ok/1)
      |> Enum.unzip()
      |> Tuple.to_list()
      |> Enum.map(fn list ->
        list
        |> Enum.count(& &1)
      end)

    twos * threes
  end

  def id_ok(binary) do
    uniques =
      binary
      |> String.graphemes()
      |> Enum.sort()
      |> Enum.chunk_by(& &1)
      |> Enum.map(&Enum.count/1)
      |> Enum.reduce(MapSet.new(), fn n, acc -> MapSet.put(acc, n) end)

    {MapSet.member?(uniques, 2), MapSet.member?(uniques, 3)}
  end

  def common_letters(ids) do
    ids
    |> Enum.reduce_while(MapSet.new(), fn id, seen ->
      id_len = String.length(id)

      case 0..(id_len - 1)
           |> Enum.reduce_while(seen, fn n, acc ->
             pair = convert_to_pairs(id, n)

             if pair in seen do
               {:halt, Enum.join(pair, "")}
             else
               {:cont, MapSet.put(acc, pair)}
             end
           end) do
        <<b::binary>> ->
          {:halt, b}

        %MapSet{} = seen ->
          {:cont, seen}
      end
    end)
  end

  defp convert_to_pairs(id, n) do
    if n == 0 do
      [String.slice(id, (n + 1)..-1)]
    else
      [String.slice(id, 0..(n - 1)), String.slice(id, (n + 1)..-1)]
    end
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case

      import Day2

      test "id_ok" do
        assert id_ok("abcdef") == {false, false}
        assert id_ok("bababc") == {true, true}
        assert id_ok("abbcde") == {true, false}
        assert id_ok("abcccd") == {false, true}
        assert id_ok("aabcdd") == {true, false}
        assert id_ok("abcdee") == {true, false}
        assert id_ok("ababab") == {false, true}
      end

      test "checksum" do
        {:ok, io} =
          StringIO.open("""
          abcdef
          bababc
          abbcde
          abcccd
          aabcdd
          abcdee
          ababab
          """)

        assert checksum(io |> IO.stream(:line) |> Stream.map(&String.trim/1)) == 12
      end

      test "common_letters" do
        {:ok, io} =
          StringIO.open("""
          abcde
          fghij
          klmno
          pqrst
          fguij
          axcye
          wvxyz
          """)

        assert common_letters(io |> IO.stream(:line) |> Stream.map(&String.trim/1)) == "fgij"
      end
    end

  [input_file] ->
    File.stream!(input_file)
    |> Stream.map(&String.trim/1)
    |> Day2.checksum()
    |> IO.puts()

  [input_file, "-2"] ->
    File.stream!(input_file)
    |> Stream.map(&String.trim/1)
    |> Day2.common_letters()
    |> IO.puts()

  _ ->
    IO.puts("""
    Usage:
      elixir day2.exs --test
      elixir day2.exs input_file
      elixir day2.exs input_file -2
    """)
end
