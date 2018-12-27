defmodule TerrainState do
  defstruct depth: 0,
            target: {-1, -1},
            terrain_info_by_coordinate: %{}

  def new(depth, {tx, ty} = target)
      when is_integer(depth) and is_integer(tx) and is_integer(ty) do
    %TerrainState{depth: depth, target: target}
  end

  def get_target(%TerrainState{target: t}), do: t

  def get_terrain_info(%TerrainState{terrain_info_by_coordinate: ti} = state, {x, y}) do
    terrain_info = Map.get(ti, {x, y})

    if terrain_info == nil do
      calculate_terrain_info_at_coordinate(state, {x, y})
    else
      {state, terrain_info}
    end
  end

  defp calculate_terrain_info_at_coordinate(
        %TerrainState{depth: d, terrain_info_by_coordinate: ti} = state,
        {x, y}
      ) do
    {state, geologic_index} = calculate_geologic_index(state, {x, y})
    erosion_level = rem(geologic_index + d, 20183)
    terrain_type = rem(erosion_level, 3)

    terrain_info = {geologic_index, erosion_level, terrain_type}
    ti = Map.put(ti, {x, y}, terrain_info)
    state = Map.put(state, :terrain_info_by_coordinate, ti)

    {state, terrain_info}
  end

  defp calculate_geologic_index(state, {0, 0}), do: {state, 0}

  defp calculate_geologic_index(%TerrainState{target: {tx, ty}} = state, {x, y})
       when x == tx and y == ty,
       do: {state, 0}

  defp calculate_geologic_index(state, {x, 0}), do: {state, x * 16807}
  defp calculate_geologic_index(state, {0, y}), do: {state, y * 48271}

  defp calculate_geologic_index(state, {x, y}) do
    {state, {_geologic_index, erosion_level_1, _terrain_type}} =
      get_terrain_info(state, {x - 1, y})

    {state, {_geologic_index, erosion_level_2, _terrain_type}} =
      get_terrain_info(state, {x, y - 1})

    {state, erosion_level_1 * erosion_level_2}
  end
end
