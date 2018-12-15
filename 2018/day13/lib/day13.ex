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

  @doc ~S"""
  Last cart position

  ## Examples

      iex> File.read!("test2.txt") |> String.trim_trailing() |> String.split("\n") |> Day13.last_pos()
      "6,4"

  """
  def last_pos(input) do
    {track, carts} =
      input
      |> Enum.with_index()
      |> parse_input()

    step_and_remove(track, carts)
  end

  def step_and_remove(track, carts) do
    {carts, _crashed} =
      carts
      |> Enum.reduce({carts, MapSet.new()}, fn {{x, y} = pos, {direction, next_turn}},
                                               {carts, crashed} ->
        carts = carts |> Map.delete(pos)

        if Map.get(crashed, pos) == nil do
          {vx, vy} = Map.get(@dir_to_coord, direction)
          next_pos = {x + vx, y + vy}

          if Map.has_key?(carts, next_pos) do
            # something is there, crashed
            crashed
            |> MapSet.put(next_pos)
            |> MapSet.put(pos)

            carts = Map.delete(carts, next_pos)

            {carts, crashed}
          else
            track_piece = Map.get(track, next_pos)
            heading = get_new_heading({direction, next_turn}, track_piece)

            carts = carts |> Map.put(next_pos, heading)

            {carts, crashed}
          end
        else
          {carts, crashed}
        end
      end)

    if map_size(carts) <= 1 do
      carts
      |> Map.to_list()
      |> Enum.at(0)
      |> elem(0)
      |> Tuple.to_list()
      |> Enum.join(",")
    else
      step_and_remove(track, carts)
    end
  end

  @doc """
  """
  def step(_track, {:crash, coordinate}, _i) do
    coordinate |> Tuple.to_list() |> Enum.join(",")
  end

  def step(track, carts, i) do
    carts =
      carts
      |> Enum.reduce_while(%{}, fn {{x, y} = pos, {direction, next_turn}}, new_carts ->
        {vx, vy} = Map.get(@dir_to_coord, direction)
        next_pos = {x + vx, y + vy}

        if crashed?(pos, next_pos, carts, new_carts) do
          {:halt, {:crash, next_pos}}
        else
          track_piece = Map.get(track, next_pos)
          heading = get_new_heading({direction, next_turn}, track_piece)

          {:cont, Map.put(new_carts, next_pos, heading)}
        end
      end)

    # carts cycle :left, :straight, :right
    step(track, carts, i + 1)
  end

  def crashed?({x, y}, {x2, y2} = next_pos, carts, new_carts) do
    cart_at_new_position = Map.get(carts, next_pos)
    cart_moved_to_new_position = Map.get(new_carts, next_pos)

    cond do
      cart_at_new_position != nil ->
        # there's a cart in the position we want to go to
        # check if we're going to crash
        #
        # ie. this should not crash
        # ++  +  >v  =  +>
        # ++     ++     +v
        {other_cart_direction, _next_turn} = cart_at_new_position
        {v2x, v2y} = Map.get(@dir_to_coord, other_cart_direction)

        if v2x + x2 == x and v2y + y2 == y do
          true
        else
          false
        end

      cart_at_new_position == nil and cart_moved_to_new_position == nil ->
        false

      true ->
        true
    end
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

  ## Examples

      iex> Day13.first_half()
      "26,99"

  """
  def first_half() do
    File.read!("input.txt")
    |> String.trim_trailing()
    |> String.split("\n")
    |> detect_crash()
  end

  @doc """
  """
  def second_half() do
    File.read!("input.txt")
    |> String.trim_trailing()
    |> String.split("\n")
    |> last_pos()
  end
end
