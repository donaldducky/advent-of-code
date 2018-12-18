defmodule Day16 do
  @moduledoc """
  Documentation for Day16.
  """
  use Bitwise

  @doc """
  """
  def parse_samples(samples) do
    samples
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn sample ->
      sample
      |> Enum.map(fn line ->
        {:ok, list, _, _, _, _} = LineParser.sample(line)
        list
      end)
    end)
  end

  def count_opcode_behaviours(samples, n) do
    samples
    |> Enum.count(&(count_behaviours(&1, n) >= n))
  end

  @ops [
    :op_addr,
    :op_addi,
    :op_mulr,
    :op_muli,
    :op_banr,
    :op_bani,
    :op_borr,
    :op_bori,
    :op_setr,
    :op_seti,
    :op_gtir,
    :op_gtri,
    :op_gtrr,
    :op_eqir,
    :op_eqri,
    :op_eqrr
  ]
  @doc """
  iex> Day16.count_behaviours([[3, 2, 1, 1], [9, 2, 1, 2], [3, 2, 2, 1]], 3)
  3
  """
  def count_behaviours(
        [
          [_r0, _r1, _r2, _r3] = register_values,
          [_op, a, b, c],
          [_r0_result, _r1_result, _r2_result, _r3_result] = result_values
        ],
        n
      ) do
    registers =
      0..3
      |> Enum.zip(register_values)
      |> Enum.into(%{})

    @ops
    |> Enum.reduce_while(0, fn op, sum ->
      result =
        apply(Day16, op, [registers, a, b, c])
        |> Enum.unzip()
        |> elem(1)

      sum =
        case result do
          ^result_values -> sum + 1
          _ -> sum
        end

      if sum >= n do
        {:halt, sum}
      else
        {:cont, sum}
      end
    end)
  end

  @doc """
  addr (add register) stores into register C the result of adding register A and register B.

  iex> Day16.op_addr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 10, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_addr(registers, a, b, c) do
    sum = Map.get(registers, a) + Map.get(registers, b)
    Map.put(registers, c, sum)
  end

  @doc """
  addi (add immediate) stores into register C the result of adding register A and value B.

  iex> Day16.op_addi(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 4, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_addi(registers, a, b, c) do
    sum = Map.get(registers, a) + b
    Map.put(registers, c, sum)
  end

  @doc """
  mulr (multiply register) stores into register C the result of multiplying register A and register B.

  iex> Day16.op_mulr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 21, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_mulr(registers, a, b, c) do
    val = Map.get(registers, a) * Map.get(registers, b)
    Map.put(registers, c, val)
  end

  @doc """
  muli (multiply immediate) stores into register C the result of multiplying register A and value B.

  iex> Day16.op_muli(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 3, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_muli(registers, a, b, c) do
    val = Map.get(registers, a) * b
    Map.put(registers, c, val)
  end

  @doc """
  banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.

  iex> Day16.op_banr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 3, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_banr(registers, a, b, c) do
    val = Map.get(registers, a) &&& Map.get(registers, b)
    Map.put(registers, c, val)
  end

  @doc """
  bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.

  iex> Day16.op_bani(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_bani(registers, a, b, c) do
    val = Map.get(registers, a) &&& b
    Map.put(registers, c, val)
  end

  @doc """
  borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.

  iex> Day16.op_borr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 7, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_borr(registers, a, b, c) do
    val = Map.get(registers, a) ||| Map.get(registers, b)
    Map.put(registers, c, val)
  end

  @doc """
  bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.

  iex> Day16.op_bori(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 3, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_bori(registers, a, b, c) do
    val = Map.get(registers, a) ||| b
    Map.put(registers, c, val)
  end

  @doc """
  setr (set register) copies the contents of register A into register C. (Input B is ignored.)

  iex> Day16.op_setr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 3, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_setr(registers, a, _b, c) do
    val = Map.get(registers, a)
    Map.put(registers, c, val)
  end

  @doc """
  seti (set immediate) stores value A into register C. (Input B is ignored.)

  iex> Day16.op_seti(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 2, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_seti(registers, a, _b, c) do
    val = a
    Map.put(registers, c, val)
  end

  @doc """
  gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B.
  Otherwise, register C is set to 0.

  iex> Day16.op_gtir(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.op_gtir(%{0 => 1, 1 => 1, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 1, 1 => 1, 2 => 3, 3 => 2}
  """
  def op_gtir(registers, a, b, c) do
    val =
      if a > Map.get(registers, b) do
        1
      else
        0
      end

    Map.put(registers, c, val)
  end

  @doc """
  gtri (greater-than register/immediate) sets register C to 1 if register A is greater than value B.
  Otherwise, register C is set to 0.

  iex> Day16.op_gtri(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 7, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.op_gtri(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_gtri(registers, a, b, c) do
    val =
      if Map.get(registers, a) > b do
        1
      else
        0
      end

    Map.put(registers, c, val)
  end

  @doc """
  gtrr (greater-than register/register) sets register C to 1 if register A is greater than register B.
  Otherwise, register C is set to 0.

  iex> Day16.op_gtrr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.op_gtrr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 1, 2, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_gtrr(registers, a, b, c) do
    val =
      if Map.get(registers, a) > Map.get(registers, b) do
        1
      else
        0
      end

    Map.put(registers, c, val)
  end

  @doc """
  eqir (equal immediate/register) sets register C to 1 if value A is equal to register B.
  Otherwise, register C is set to 0.

  iex> Day16.op_eqir(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.op_eqir(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 3, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_eqir(registers, a, b, c) do
    val =
      if a == Map.get(registers, b) do
        1
      else
        0
      end

    Map.put(registers, c, val)
  end

  @doc """
  eqri (equal register/immediate) sets register C to 1 if register A is equal to value B.
  Otherwise, register C is set to 0.

  iex> Day16.op_eqri(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.op_eqri(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 3, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def op_eqri(registers, a, b, c) do
    val =
      if Map.get(registers, a) == b do
        1
      else
        0
      end

    Map.put(registers, c, val)
  end

  @doc """
  eqrr (equal register/register) sets register C to 1 if register A is equal to register B.
  Otherwise, register C is set to 0.

  iex> Day16.op_eqrr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.op_eqrr(%{0 => 1, 1 => 3, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 1, 1 => 3, 2 => 3, 3 => 2}
  """
  def op_eqrr(registers, a, b, c) do
    val =
      if Map.get(registers, a) == Map.get(registers, b) do
        1
      else
        0
      end

    Map.put(registers, c, val)
  end

  def first_half() do
    [samples, _test] =
      File.read!("input.txt")
      |> String.split("\n\n\n\n", trim: true)

    samples
    |> parse_samples()
    |> count_opcode_behaviours(3)
  end
end

defmodule LineParser do
  import NimbleParsec

  instruction =
    integer(min: 1, max: 2)
    |> ignore(string(" "))
    |> integer(min: 1, max: 2)
    |> ignore(string(" "))
    |> integer(min: 1, max: 2)
    |> ignore(string(" "))
    |> integer(min: 1, max: 2)

  input =
    ignore(string("Before: ["))
    |> integer(min: 1, max: 2)
    |> ignore(string(", "))
    |> integer(min: 1, max: 2)
    |> ignore(string(", "))
    |> integer(min: 1, max: 2)
    |> ignore(string(", "))
    |> integer(min: 1, max: 2)
    |> ignore(string("]"))

  output =
    ignore(string("After:  ["))
    |> integer(min: 1, max: 2)
    |> ignore(string(", "))
    |> integer(min: 1, max: 2)
    |> ignore(string(", "))
    |> integer(min: 1, max: 2)
    |> ignore(string(", "))
    |> integer(min: 1, max: 2)
    |> ignore(string("]"))

  sample =
    choice([
      input,
      instruction,
      output
    ])

  defparsec(:sample, sample)
end
