defmodule Day19 do
  @moduledoc """
  Documentation for Day19.
  """

  def parse_program(lines) do
    lines
    |> Enum.map(fn line ->
      case LineParser.line(line) do
        {:ok, [ip_register], _, _, _, _} ->
          ip_register

        {:ok, [op, a, b, c], _, _, _, _} ->
          {String.to_atom(op), a, b, c}
      end
    end)
  end

  def execute_program([instruction_pointer_register | instructions], r0) do
    program_listing =
      instructions
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {instruction, index}, program_listing ->
        Map.put(program_listing, index, instruction)
      end)

    registers =
      0..5
      |> Enum.zip([r0 | List.duplicate(0, 5)])
      |> Enum.into(%{})

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while(registers, fn i, registers ->
      if i > 100 do
        raise "quitting after #{i} iterations"
      end

      line_number = Map.get(registers, instruction_pointer_register)

      IO.write("ip=#{line_number} " |> String.pad_leading(6, " "))
      IO.write("[#{registers |> Enum.unzip() |> elem(1) |> Enum.join(", ")}] ")

      case Map.get(program_listing, line_number) do
        nil ->
          {:halt, Map.get(registers, 0)}

        {op, a, b, c} ->
          registers = apply(Day16, op, [registers, a, b, c])

          IO.write("#{op} #{a} #{b} #{c} ")
          IO.write("[#{registers |> Enum.unzip() |> elem(1) |> Enum.join(", ")}]\n")

          registers = registers |> Map.update!(instruction_pointer_register, &(&1 + 1))

          {:cont, registers}
      end
    end)
  end

  @doc """
  """
  def first_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_program()
    |> execute_program(0)
  end

  @doc """
  1..10551310
  |> Stream.filter(&(rem(10551309, &1) == 0))
  |> Enum.sum()
  14562240
  """
  def second_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_program()
    |> execute_program(1)
  end
end
