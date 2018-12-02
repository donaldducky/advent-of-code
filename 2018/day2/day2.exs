defmodule Day2 do
  def checksum(ids) do
    {twos, threes} =
      ids
      |> Stream.map(&id_ok/1)
      |> Enum.reduce({0, 0}, fn {a, b}, {x, y} -> {a + x, b + y} end)

    twos * threes
  end

  def id_ok(binary) do
    binary
    |> count_letters
    |> Enum.reduce({0, 0}, fn {_k, v}, {twos, threes} = acc ->
      case v do
        2 ->
          {1, threes}

        3 ->
          {twos, 1}

        _ ->
          acc
      end
    end)
  end

  def common_letters(ids) do
    ids
    |> Enum.reduce_while(MapSet.new(), fn id, seen ->
      id_len = String.length(id)

      case 0..(id_len - 1)
           |> Enum.reduce_while(seen, fn n, acc ->
             removed = remove_letter(id, n)
             t = {n, removed}

             if t in seen do
               {:halt, removed}
             else
               {:cont, MapSet.put(acc, t)}
             end
           end) do
        <<b::binary>> ->
          {:halt, b}

        %MapSet{} = seen ->
          {:cont, seen}
      end
    end)
  end

  defp remove_letter(id, n) do
    if n == 0 do
      String.slice(id, (n + 1)..-1)
    else
      String.slice(id, 0..(n - 1)) <> String.slice(id, (n + 1)..-1)
    end
  end

  defp count_letters(binary) do
    count_letters(binary, %{})
  end

  defp count_letters(<<c::utf8, rest::binary>>, letter_counts) do
    n =
      case Map.get(letter_counts, c) do
        nil ->
          0

        val ->
          val
      end

    count_letters(rest, Map.put(letter_counts, c, n + 1))
  end

  defp count_letters("", letter_counts) do
    letter_counts
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day2Test do
      use ExUnit.Case

      import Day2

      test "id_ok" do
        assert id_ok("abcdef") == {0, 0}
        assert id_ok("bababc") == {1, 1}
        assert id_ok("abbcde") == {1, 0}
        assert id_ok("abcccd") == {0, 1}
        assert id_ok("aabcdd") == {1, 0}
        assert id_ok("abcdee") == {1, 0}
        assert id_ok("ababab") == {0, 1}
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
