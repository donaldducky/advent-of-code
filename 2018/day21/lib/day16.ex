# These instructions were copied from Day16
defmodule Day16 do
  use Bitwise

  @doc """
  addr (add register) stores into register C the result of adding register A and register B.

  iex> Day16.addr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 10, 1 => 7, 2 => 3, 3 => 2}
  """
  def addr(registers, a, b, c) do
    sum = Map.get(registers, a) + Map.get(registers, b)
    Map.put(registers, c, sum)
  end

  @doc """
  addi (add immediate) stores into register C the result of adding register A and value B.

  iex> Day16.addi(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 4, 1 => 7, 2 => 3, 3 => 2}
  """
  def addi(registers, a, b, c) do
    sum = Map.get(registers, a) + b
    Map.put(registers, c, sum)
  end

  @doc """
  mulr (multiply register) stores into register C the result of multiplying register A and register B.

  iex> Day16.mulr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 21, 1 => 7, 2 => 3, 3 => 2}
  """
  def mulr(registers, a, b, c) do
    val = Map.get(registers, a) * Map.get(registers, b)
    Map.put(registers, c, val)
  end

  @doc """
  muli (multiply immediate) stores into register C the result of multiplying register A and value B.

  iex> Day16.muli(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 3, 1 => 7, 2 => 3, 3 => 2}
  """
  def muli(registers, a, b, c) do
    val = Map.get(registers, a) * b
    Map.put(registers, c, val)
  end

  @doc """
  banr (bitwise AND register) stores into register C the result of the bitwise AND of register A and register B.

  iex> Day16.banr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 3, 1 => 7, 2 => 3, 3 => 2}
  """
  def banr(registers, a, b, c) do
    val = Map.get(registers, a) &&& Map.get(registers, b)
    Map.put(registers, c, val)
  end

  @doc """
  bani (bitwise AND immediate) stores into register C the result of the bitwise AND of register A and value B.

  iex> Day16.bani(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def bani(registers, a, b, c) do
    val = Map.get(registers, a) &&& b
    Map.put(registers, c, val)
  end

  @doc """
  borr (bitwise OR register) stores into register C the result of the bitwise OR of register A and register B.

  iex> Day16.borr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 7, 1 => 7, 2 => 3, 3 => 2}
  """
  def borr(registers, a, b, c) do
    val = Map.get(registers, a) ||| Map.get(registers, b)
    Map.put(registers, c, val)
  end

  @doc """
  bori (bitwise OR immediate) stores into register C the result of the bitwise OR of register A and value B.

  iex> Day16.bori(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 3, 1 => 7, 2 => 3, 3 => 2}
  """
  def bori(registers, a, b, c) do
    val = Map.get(registers, a) ||| b
    Map.put(registers, c, val)
  end

  @doc """
  setr (set register) copies the contents of register A into register C. (Input B is ignored.)

  iex> Day16.setr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 3, 1 => 7, 2 => 3, 3 => 2}
  """
  def setr(registers, a, _b, c) do
    val = Map.get(registers, a)
    Map.put(registers, c, val)
  end

  @doc """
  seti (set immediate) stores value A into register C. (Input B is ignored.)

  iex> Day16.seti(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 2, 1 => 7, 2 => 3, 3 => 2}
  """
  def seti(registers, a, _b, c) do
    val = a
    Map.put(registers, c, val)
  end

  @doc """
  gtir (greater-than immediate/register) sets register C to 1 if value A is greater than register B.
  Otherwise, register C is set to 0.

  iex> Day16.gtir(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.gtir(%{0 => 1, 1 => 1, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 1, 1 => 1, 2 => 3, 3 => 2}
  """
  def gtir(registers, a, b, c) do
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

  iex> Day16.gtri(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 7, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.gtri(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def gtri(registers, a, b, c) do
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

  iex> Day16.gtrr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.gtrr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 1, 2, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def gtrr(registers, a, b, c) do
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

  iex> Day16.eqir(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.eqir(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 3, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def eqir(registers, a, b, c) do
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

  iex> Day16.eqri(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.eqri(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 3, 0)
  %{0 => 1, 1 => 7, 2 => 3, 3 => 2}
  """
  def eqri(registers, a, b, c) do
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

  iex> Day16.eqrr(%{0 => 1, 1 => 7, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 0, 1 => 7, 2 => 3, 3 => 2}

  iex> Day16.eqrr(%{0 => 1, 1 => 3, 2 => 3, 3 => 2}, 2, 1, 0)
  %{0 => 1, 1 => 3, 2 => 3, 3 => 2}
  """
  def eqrr(registers, a, b, c) do
    val =
      if Map.get(registers, a) == Map.get(registers, b) do
        1
      else
        0
      end

    Map.put(registers, c, val)
  end
end
