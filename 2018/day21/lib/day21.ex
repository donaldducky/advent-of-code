defmodule Day21 do
  import Bitwise

  @moduledoc """
  Documentation for Day21.
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

  def execute_program([instruction_pointer_register | instructions], r0, quit_after_iterations) do
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
      # if i >= quit_after_iterations do
      #  raise "quitting after #{i} iterations"
      # end

      line_number = Map.get(registers, instruction_pointer_register)

      # IO.write("ip=#{line_number} " |> String.pad_leading(6, " "))
      # IO.write("[#{registers |> Enum.unzip() |> elem(1) |> Enum.join(", ")}] ")

      if line_number == 28 do
        raise "hit line 28 register 3 contains #{Map.get(registers, 3)}"
      end

      case Map.get(program_listing, line_number) do
        nil ->
          {:halt, Map.get(registers, 0)}

        {op, a, b, c} ->
          registers = apply(Day16, op, [registers, a, b, c])

          # IO.write("#{op} #{a} #{b} #{c} ")
          # IO.write("[#{registers |> Enum.unzip() |> elem(1) |> Enum.join(", ")}]\n")

          registers = registers |> Map.update!(instruction_pointer_register, &(&1 + 1))

          {:cont, registers}
      end
    end)
  end

  def execute_program2([instruction_pointer_register | instructions]) do
    program_listing =
      instructions
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {instruction, index}, program_listing ->
        Map.put(program_listing, index, instruction)
      end)

    registers =
      0..5
      |> Enum.zip(List.duplicate(0, 6))
      |> Enum.into(%{})

    found = MapSet.new()

    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({registers, found, 0}, fn i, {registers, found, prev} ->
      line_number = Map.get(registers, instruction_pointer_register)

      case Map.get(program_listing, line_number) do
        nil ->
          {:halt, Map.get(registers, 0)}

        {op, a, b, c} ->
          {found, r3} =
            if line_number == 28 do
              r3 =
                Map.get(registers, 3)
                |> IO.inspect(label: "r3 (#{i})")

              if MapSet.member?(found, r3) do
                found
                |> IO.inspect(label: "found")
                |> MapSet.size()
                |> IO.inspect(label: "# found")

                raise "Found repeat #{r3} at iteration #{i} previous value is #{prev}"
              end

              found = MapSet.put(found, r3)
              {found, r3}
            else
              {found, prev}
            end

          registers = apply(Day16, op, [registers, a, b, c])

          registers = registers |> Map.update!(instruction_pointer_register, &(&1 + 1))

          {:cont, {registers, found, r3}}
      end
    end)
  end

  @doc """
  "iex> Day21.first_half()
  "3173684
  """
  def first_half() do
    File.read!("input.txt")
    |> String.split("\n", trim: true)
    |> parse_program()
    |> execute_program(0, 50)
  end

  @doc """
  "iex> Day21.second_half()
  "12464363
  """
  def second_half() do
    program =
      File.read!("input.txt")
      |> String.split("\n", trim: true)
      |> parse_program()
      |> execute_program2()
  end
end
