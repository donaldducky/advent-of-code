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
  def marble_madness(input), do: marble_madness(input, 1)

  def marble_madness(input, multiplier) do
    [num_players, max_value] =
      input
      |> LineParser.players_points()
      |> elem(1)

    max_value = max_value * multiplier

    board = Board.new()
    value = 0
    scores = Tuple.duplicate(0, num_players)

    # setup
    0..max_value
    |> Enum.reduce({board, scores}, fn
      0, {board, scores} ->
        {take_turn(board, value), scores}

      value, {board, scores} when rem(value, 23) == 0 ->
        # subtract 1 because tuple is zero indexed
        player_index = rem(value, num_players)
        {board, points_captured} = capture_marble(board)

        player_score =
          scores
          |> elem(player_index)
          |> Kernel.+(value)
          |> Kernel.+(points_captured)

        scores =
          scores
          |> put_elem(player_index, player_score)

        {board, scores}

      value, {board, scores} ->
        {take_turn(board, value), scores}
    end)
    |> elem(1)
    |> Tuple.to_list()
    |> Enum.max()
  end

  @doc """
  Take a turn
  """
  def take_turn(board, value) do
    board
    |> Board.clockwise()
    |> Board.insert(value)
  end

  @doc """
  Capture a marble by moving 7 counter-clockwise and removing the marble.
  Sets the index to the marble occupying the old spot.

  """
  def capture_marble(board) do
    board =
      1..7
      |> Enum.reduce(board, fn _, board ->
        board |> Board.counter_clockwise()
      end)

    points = board |> Board.head()

    board = board |> Board.remove()

    {board, points}
  end

  def first_half() do
    read_input()
    |> marble_madness()
  end

  def second_half() do
    read_input()
    |> marble_madness(100)
  end

  @spec read_input() :: Enumerable.t()
  def read_input() do
    File.read!("input.txt")
    |> String.trim()
  end
end

defmodule Board do
  def new() do
    [[], []]
  end

  @doc """
  Get value of current position

  ## Examples

      iex> Board.new() |> Board.head()
      nil

  """
  def head([[], []]), do: nil
  def head([[head | _tail], _]), do: head

  @doc """
  Insert at current position

  ## Examples

      iex> Board.new() |> Board.insert(0) |> Board.head()
      0
      iex> Board.new() |> Board.insert(0) |> Board.insert(1) |> Board.head()
      1

  """
  def insert([list1, list2], val) do
    [[val | list1], list2]
  end

  @doc """
  Remove current position

  ## Examples

      iex> Board.remove([[], []])
      [[], []]
      iex> Board.remove([[0], []])
      [[], []]
      iex> Board.remove([[2, 0], [1]])
      [[1, 0], []]
      iex> Board.remove([[3, 1, 2, 0], []])
      [[0], [2, 1]]

  """
  def remove([[], []] = board), do: board

  def remove([[_head | tail], list2]) do
    [tail, list2]
    |> Board.clockwise()
  end

  @doc """
  Move current position clockwise (right) and wrap around if at bounds

  ## Examples

      iex> Board.clockwise([[], []])
      [[], []]
      iex> Board.clockwise([[0], []])
      [[0], []]
      iex> Board.clockwise([[1, 0], []])
      [[0], [1]]
      iex> Board.clockwise([[0], [1]])
      [[1, 0], []]
      iex> Board.clockwise([[3, 1, 2, 0], []])
      [[0], [2, 1, 3]]
      iex> Board.clockwise([[0], [2, 1, 3]])
      [[2, 0], [1, 3]]

  """
  def clockwise([[], []] = board), do: board
  def clockwise([[_], []] = board), do: board

  def clockwise([list1, []]) do
    [head | tail] = list1 |> Enum.reverse()
    [[head], tail]
  end

  def clockwise([list1, [head2 | tail2]]) do
    [[head2 | list1], tail2]
  end

  @doc """
  Move current position counter-clockwise (left) and wrap around if at bounds

  ## Examples

      iex> Board.counter_clockwise([[], []])
      [[], []]
      iex> Board.counter_clockwise([[0], []])
      [[0], []]
      iex> Board.counter_clockwise([[1, 0], []])
      [[0], [1]]
      iex> Board.counter_clockwise([[0], [1]])
      [[1, 0], []]
      iex> Board.counter_clockwise([[3, 1, 2, 0], []])
      [[1, 2, 0], [3]]
      iex> Board.counter_clockwise([[0], [2, 1, 3]])
      [[3, 1, 2, 0], []]

  """
  def counter_clockwise([[], []] = board), do: board
  def counter_clockwise([[_], []] = board), do: board

  def counter_clockwise([[head], list2]) do
    [[head | list2] |> Enum.reverse(), []]
  end

  def counter_clockwise([[head | tail], list2]) do
    [tail, [head | list2]]
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
