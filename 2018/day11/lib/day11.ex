defmodule Day11 do
  @moduledoc """
  Documentation for Day11.
  """

  @doc """
  Top left coordinate of 3x3 grid with largest power.

  ## Examples

      iex> Day11.largest_power_grid(18)
      "33,45"
      iex> Day11.largest_power_grid(42)
      "21,61"

  """
  def largest_power_grid(serial_number) do
    Enum.reduce(1..300, {%{}, %{coordinate: nil, grid_power_level: 0}}, fn y, power_levels ->
      Enum.reduce(1..300, power_levels, fn x, {power_levels, current_max} ->
        power_levels =
          power_levels
          |> Map.put({x, y}, power_level(x, y, serial_number))

        current_max = calculate_grid_power({x, y}, power_levels, current_max)

        {power_levels, current_max}
      end)
    end)
    |> elem(1)
    |> Map.get(:coordinate)
    |> Tuple.to_list()
    |> Enum.join(",")
  end

  def calculate_grid_power(
        {x, y},
        power_levels,
        %{grid_power_level: current_power_level} = current_best
      )
      when x > 2 and y > 2 do
    cx = x - 2
    cy = y - 2

    power_level =
      Enum.reduce(cx..x, 0, fn x, power_level ->
        Enum.reduce(cy..y, power_level, fn y, power_level ->
          power_level + Map.get(power_levels, {x, y})
        end)
      end)

    if power_level > current_power_level do
      %{coordinate: {cx, cy}, grid_power_level: power_level}
    else
      current_best
    end
  end

  def calculate_grid_power(_, _power_levels, current_best), do: current_best

  @doc """
  ## Examples

      iex> Day11.power_level(3, 5, 8)
      4
      iex> Day11.power_level(122, 79, 57)
      -5
      iex> Day11.power_level(217, 196, 39)
      0
      iex> Day11.power_level(101, 153, 71)
      4

  """
  def power_level(x, y, serial_number) do
    rack_id = x + 10

    rack_id
    |> Kernel.*(y)
    |> Kernel.+(serial_number)
    |> Kernel.*(rack_id)
    |> div(100)
    |> rem(10)
    |> Kernel.-(5)
  end

  def first_half() do
    largest_power_grid(1309)
  end
end
