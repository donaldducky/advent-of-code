defmodule Day15Node do
  defstruct x: 0, y: 0, depth: 0, prev: nil

  def new(x, y) do
    %Day15Node{x: x, y: y}
  end

  def new(x, y, %Day15Node{} = n) do
    %Day15Node{x: x, y: y, depth: n.depth + 1, prev: {n.x, n.y}}
  end

  def new(x, y, d) when is_integer(d) do
    %Day15Node{x: x, y: y, depth: d}
  end
end
