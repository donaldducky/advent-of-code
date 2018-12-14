defmodule Day13 do
  @dir_to_coord %{
    north: {0, -1},
    south: {0, 1},
    east: {1, 0},
    west: {-1, 0}
  }

  @moduledoc """
  Documentation for Day13.
  """

  @doc ~S"""
  Where does the first crash happen?

  ## Examples

      iex> File.read!("test1.txt") |> String.trim_trailing() |> String.split("\n") |> Day13.detect_crash()
      "7,3"

  """
  def detect_crash(input) do
    {track, carts} =
      input
      |> Enum.with_index()
      |> parse_input()

    step(track, carts, 0)
  end

  def parse_input(input) do
    input
    |> Enum.reduce({%{}, %{}}, fn {line, y}, acc ->
      line
      |> String.to_charlist()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {?\s, _x}, acc ->
          acc

        {c, x}, {track, carts} when c == ?/ or c == ?\\ or c == ?| or c == ?- or c == ?+ ->
          {Map.put(track, {x, y}, c), carts}

        {c, x}, {track, carts} when c == ?> ->
          track = Map.put(track, {x, y}, ?-)
          carts = Map.put(carts, {x, y}, {:east, :left})
          {track, carts}

        {c, x}, {track, carts} when c == ?< ->
          track = Map.put(track, {x, y}, ?-)
          carts = Map.put(carts, {x, y}, {:west, :left})
          {track, carts}

        {c, x}, {track, carts} when c == ?^ ->
          track = Map.put(track, {x, y}, ?|)
          carts = Map.put(carts, {x, y}, {:north, :left})
          {track, carts}

        {c, x}, {track, carts} when c == ?v ->
          track = Map.put(track, {x, y}, ?|)
          carts = Map.put(carts, {x, y}, {:south, :left})
          {track, carts}

        {c, x}, _acc ->
          IO.inspect(c, label: "unknown char at #{x} #{y}")
          raise "error"
      end)
    end)
  end

  @doc """
  """
  def step(_track, {:crash, coordinate}, _i) do
    coordinate |> Tuple.to_list() |> Enum.join(",")
  end

  def step(track, carts, i) do
    # i |> IO.inspect(label: "iteration")
    # {w, _} = track |> Enum.to_list() |> Enum.max_by(fn {{x, _y}, _v} -> x end) |> elem(0)
    # {_, h} = track |> Enum.to_list() |> Enum.max_by(fn {{_x, y}, _v} -> y end) |> elem(0)
    # IO.inspect([w, h])

    # 0..h
    # |> Enum.each(fn y ->
    #  0..w
    #  |> Enum.each(fn x ->
    #    c =
    #      if Map.get(carts, {x, y}) == nil do
    #        Map.get(track, {x, y}, ?\s)
    #      else
    #        "█" |> String.to_charlist()
    #      end

    #    IO.write([c])
    #  end)

    #  IO.puts("")
    # end)

    carts =
      carts
      |> Enum.reduce_while(%{}, fn {{x, y}, {direction, next_turn}}, new_carts ->
        {vx, vy} = Map.get(@dir_to_coord, direction)
        x2 = x + vx
        y2 = y + vy

        cond do
          Map.get(carts, {x2, y2}) != nil ->
            # there's a cart in the position we want to go to
            # check if we're going to crash
            #
            # ie. this should not crash
            # ++ -> ab -> a going straight, b going left
            # ++    ++
            {other_cart_direction, _next_turn} = Map.get(carts, {x2, y2})
            {v2x, v2y} = Map.get(@dir_to_coord, other_cart_direction)

            if v2x + x2 == x and v2y + y2 == y do
              {:halt, {:crash, {x2, y2}}}
            else
              track_piece = Map.get(track, {x2, y2})
              # IO.puts("Moving from #{x},#{y} to #{x2},#{y2}")
              heading = get_new_heading({direction, next_turn}, track_piece)

              {:cont, Map.put(new_carts, {x2, y2}, heading)}
            end

          Map.get(carts, {x2, y2}) == nil and Map.get(new_carts, {x2, y2}) == nil ->
            track_piece = Map.get(track, {x2, y2})
            # IO.puts("Moving from #{x},#{y} to #{x2},#{y2}")
            heading = get_new_heading({direction, next_turn}, track_piece)

            {:cont, Map.put(new_carts, {x2, y2}, heading)}

          true ->
            # IO.puts("Crash at #{x2},#{y2}")
            {:halt, {:crash, {x2, y2}}}
        end
      end)

    # carts cycle :left, :straight, :right
    step(track, carts, i + 1)
  end

  def get_new_heading(heading, track_piece) when track_piece == ?| or track_piece == ?-,
    do: heading

  def get_new_heading({direction, next_turn}, track_piece) when track_piece == ?/ do
    next_direction =
      case direction do
        :north -> :east
        :south -> :west
        :east -> :north
        :west -> :south
      end

    {next_direction, next_turn}
  end

  def get_new_heading({direction, next_turn}, track_piece) when track_piece == ?\\ do
    next_direction =
      case direction do
        :north -> :west
        :south -> :east
        :east -> :south
        :west -> :north
      end

    {next_direction, next_turn}
  end

  def get_new_heading({direction, next_turn}, track_piece) when track_piece == ?+ do
    case next_turn do
      :left ->
        next_direction =
          case direction do
            :north -> :west
            :south -> :east
            :east -> :north
            :west -> :south
          end

        {next_direction, :straight}

      :straight ->
        {direction, :right}

      :right ->
        next_direction =
          case direction do
            :north -> :east
            :south -> :west
            :east -> :south
            :west -> :north
          end

        {next_direction, :left}
    end
  end

  def first_half() do
    File.read!("input.txt")
    |> String.trim_trailing()
    |> String.split("\n")
    |> detect_crash()
  end
end
