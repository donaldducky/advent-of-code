defmodule PathNode do
  defstruct x: 0, y: 0, equip: nil, cost: 0, prev: nil

  def new(x, y, equip) do
    %PathNode{x: x, y: y, equip: equip}
  end

  def new(x, y, e, c, %PathNode{x: px, y: py, equip: pe}) do
    %PathNode{x: x, y: y, equip: e, cost: c, prev: {px, py, pe}}
  end
end
