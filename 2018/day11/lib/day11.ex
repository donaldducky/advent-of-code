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
    largest_power_grid(serial_number, 3, 3)
  end

  def largest_power_grid(serial_number, min_grid_size, max_grid_size) do
    max_x = 300
    max_y = 300

    state = {%{}, %{coordinate: {0, 0, 0}, grid_power_level: 0}}

    {_, %{coordinate: {x, y, d}}} =
      1..max_grid_size
      |> Enum.reduce(state, fn depth, acc ->
        depth |> IO.inspect(label: "depth")

        Enum.reduce((max_y - depth + 1)..1, acc, fn y, acc ->
          Enum.reduce((max_x - depth + 1)..1, acc, fn x,
                                                      {power_levels,
                                                       %{grid_power_level: current_max} =
                                                         current_best} ->
            power_levels = calculate_power_levels({x, y}, power_levels, depth, serial_number)

            current_best =
              if depth >= min_grid_size and depth <= max_grid_size do
                power = power_levels |> Map.get({x, y, depth})

                if power > current_max do
                  %{coordinate: {x, y, depth}, grid_power_level: power}
                else
                  current_best
                end
              else
                current_best
              end

            {power_levels, current_best}
          end)
        end)
      end)

    if min_grid_size == max_grid_size do
      [x, y] |> Enum.join(",")
    else
      [x, y, d] |> Enum.join(",")
    end
  end

  def calculate_power_levels({x, y}, power_levels, depth, serial_number) when depth == 1 do
    power_levels |> Map.put({x, y, depth}, power_level(x, y, serial_number))
  end

  # 299, 299, 2 -> [{299, 299, 1}, {299, 300, 1}, {300, 299, 1}, {300, 300, 1}]
  # 298, 298, 3 -> [{298, 298, 1}, {299, 298, 1}, {300, 298, 1}, {298, 299, 1}, {298, 300, 1}, {299, 299, 2}]
  def calculate_power_levels({x, y}, power_levels, depth, _serial_number) do
    prev_grid_sum = Map.get(power_levels, {x + 1, y + 1, depth - 1})

    row_sum =
      (x + 1)..(x + depth - 1)
      |> Enum.reduce(0, fn x2, sum -> sum + Map.get(power_levels, {x2, y, 1}) end)

    col_sum =
      (y + 1)..(y + depth - 1)
      |> Enum.reduce(0, fn y2, sum -> sum + Map.get(power_levels, {x, y2, 1}) end)

    power_level = Map.get(power_levels, {x, y, 1}) + prev_grid_sum + row_sum + col_sum

    power_levels |> Map.put({x, y, depth}, power_level)
  end

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

  def second_half() do
    largest_power_grid(1309, 1, 300)
  end
end
