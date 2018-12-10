defmodule Day9 do
  @moduledoc """
  Documentation for Day9.
  """

  @doc """
  Marble madness

  ## Examples

      iex> Day9.marble_madness("9 players; last marble is worth 25 points")
      32
      iex> Day9.marble_madness("10 players; last marble is worth 1618 points")
      8317
      iex> Day9.marble_madness("13 players; last marble is worth 7999 points")
      146373
      iex> Day9.marble_madness("17 players; last marble is worth 1104 points")
      2764
      iex> Day9.marble_madness("21 players; last marble is worth 6111 points")
      54718
      iex> Day9.marble_madness("30 players; last marble is worth 5807 points")
      37305

  """
  def marble_madness(input) do
    [num_players, max_value] =
      input
      |> LineParser.players_points()
      |> elem(1)

    board = {}
    index = 0
    value = 0
    scores = Tuple.duplicate(0, num_players)

    # setup
    0..max_value
    |> Enum.reduce({board, index, scores}, fn
      0, {board, index, scores} ->
        {board, index} = take_turn(board, index, value)
        {board, index, scores}

      value, {board, index, scores} when rem(value, 23) == 0 ->
        # subtract 1 because tuple is zero indexed
        player_index = rem(value, num_players)
        {board, index, points_captured} = capture_marble(board, index)

        player_score =
          scores
          |> elem(player_index)
          |> Kernel.+(value)
          |> Kernel.+(points_captured)

        scores =
          scores
          |> put_elem(player_index, player_score)

        {board, index, scores}

      value, {board, index, scores} ->
        {board, index} = take_turn(board, index, value)
        {board, index, scores}
    end)
    |> elem(2)
    |> Tuple.to_list()
    |> Enum.max()
  end

  @doc """
  Take a turn

  ## Examples

      iex> Day9.take_turn({}, 0, 0)
      {{0}, 0}
      iex> Day9.take_turn({0}, 0, 1)
      {{0, 1}, 1}
      iex> Day9.take_turn({0, 1}, 1, 2)
      {{0, 2, 1}, 1}
      iex> Day9.take_turn({0, 2, 1}, 1, 3)
      {{0, 2, 1, 3}, 3}
      iex> Day9.take_turn({0, 8, 4, 9, 2, 10, 5, 11, 1, 12, 6, 13, 3, 14, 7, 15}, 15, 16)
      {{0, 16, 8, 4, 9, 2, 10, 5, 11, 1, 12, 6, 13, 3, 14, 7, 15}, 1}

  """
  def take_turn(board, index, value) do
    index = clockwise(board, index)

    board =
      board
      |> Tuple.insert_at(index, value)

    {board, index}
  end

  @doc """
  Capture a marble by moving 7 counter-clockwise and removing the marble.
  Sets the index to the marble occupying the old spot.

  ## Examples

      iex> Day9.capture_marble({0, 16, 8, 17, 4, 18, 9, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15}, 13)
      {{0, 16, 8, 17, 4, 18, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15}, 6, 9}
      iex> Day9.capture_marble({0, 16, 8, 17, 4, 18, 9, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 3, 14, 7, 15}, 3)
      {{0, 16, 8, 17, 4, 18, 9, 19, 2, 20, 10, 21, 5, 22, 11, 1, 12, 6, 13, 14, 7, 15}, 19, 3}

  """
  def capture_marble(board, index) when index - 7 < 0,
    do: capture_marble(board, tuple_size(board) + index)

  def capture_marble(board, index) do
    index = index - 7
    captured = board |> elem(index)
    board = board |> Tuple.delete_at(index)

    {board, index, captured}
  end

  @doc """
  Return index, given an index after moving clockwise

  ## Examples

      iex> Day9.clockwise({}, 0)
      0
      iex> Day9.clockwise({0}, 0)
      1
      iex> Day9.clockwise({0, 1}, 1)
      1
      iex> Day9.clockwise({0, 2, 1}, 1)
      3
      iex> Day9.clockwise({0, 2, 1, 3}, 3)
      1

  """
  def clockwise({}, _), do: 0
  def clockwise({_}, _), do: 1
  def clockwise({_, _}, _), do: 1
  def clockwise(board, index) when index + 2 <= tuple_size(board), do: index + 2

  def clockwise(board, index) do
    rem(index + 2, board |> tuple_size)
  end

  def first_half() do
    read_input()
    |> marble_madness()
  end

  @spec read_input() :: Enumerable.t()
  def read_input() do
    File.read!("input.txt")
    |> String.trim()
  end
end

defmodule LineParser do
  import NimbleParsec

  players_points =
    integer(min: 1)
    |> ignore(string(" players; last marble is worth "))
    |> integer(min: 1)
    |> ignore(string(" points"))

  defparsec(:players_points, players_points)
end
