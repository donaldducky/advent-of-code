defmodule Day8 do
  @moduledoc """
  Documentation for Day8.
  """

  @doc """
  Calculate sum of metadata entries.

  header consists of 2 numbers
  - # of child nodes 0..n
  - # of metadata entries 1..m

  2 child nodes, 3 metadata entries
  -> child node 0 children, 3 metadata entries, [10, 11, 12]
  -> child node 1 child, 1 metadata entry
    -> child node 0 children, 1 metadata, [99]
    -> metadata 2
  -> metdata [1, 1, 2]

  ## Examples

      iex> Day8.metadata_sum([2, 3, 0, 3, 10, 11, 12, 1, 1, 0, 1, 99, 2, 1, 1, 2])
      138

  """
  def metadata_sum(input) do
    parse_node(input)
  end

  def parse_node(input) do
    sum = 0

    {[num_children, num_metadata], input} =
      input
      |> Enum.split(2)

    {input, sum} =
      List.duplicate(0, num_children)
      |> Enum.reduce({input, sum}, fn _, {input, sum} ->
        {input, sum2} = parse_node(input)
        {input, sum + sum2}
      end)

    {metadata, input} =
      input
      |> Enum.split(num_metadata)

    sum = sum + (metadata |> Enum.sum())

    if input == [] do
      sum
    else
      {input, sum}
    end
  end

  def first_half() do
    read_input()
    |> metadata_sum()
  end

  @spec read_input() :: Enumerable.t()
  def read_input() do
    File.read!("input.txt")
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&(&1 |> Integer.parse() |> elem(0)))
  end
end
