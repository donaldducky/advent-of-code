defmodule AocHelpersTest do
  use ExUnit.Case
  doctest AocHelpers

  test "greets the world" do
    assert AocHelpers.hello() == :world
  end
end
