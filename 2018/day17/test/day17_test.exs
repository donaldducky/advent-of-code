defmodule Day17Test do
  use ExUnit.Case
  doctest Day17
  import Day17

  test "water flow does not continue forever" do
    map = """
    ......+.......
    ............#.
    .#..#.......#.
    .#..#..#......
    .#..#..#......
    .#.....#......
    .#.....#......
    .#####.#......
    ..............
    ..............
    ....#.....#...
    ....#.....#...
    ....#.....#...
    ....##.####...
    """

    expect = """
    ......+.......
    ......|.....#.
    .#..#.|.....#.
    .#..#.|#......
    .#..#.|#......
    .#....|#......
    .#....|#......
    .#####|#......
    ......|.......
    ......|.......
    ....#.|...#...
    ....#.|...#...
    ....#.|...#...
    ....##|####...
    """

    assert generate_water_flow(read_map(map)) == read_map(expect)
  end

  test "water flow" do
    map = """
    ......+.......
    ............#.
    .#..#.......#.
    .#..#..#......
    .#..#..#......
    .#.....#......
    .#.....#......
    .#######......
    ..............
    ..............
    ....#.....#...
    ....#.....#...
    ....#.....#...
    ....#######...
    """

    expect = """
    ......+.......
    ......|.....#.
    .#..#||||...#.
    .#..#~~#|.....
    .#..#~~#|.....
    .#~~~~~#|.....
    .#~~~~~#|.....
    .#######|.....
    ........|.....
    ...|||||||||..
    ...|#~~~~~#|..
    ...|#~~~~~#|..
    ...|#~~~~~#|..
    ...|#######|..
    """

    assert generate_water_flow(read_map(map)) == read_map(expect)
  end

  test "water flow clay" do
    map = """
    ......+.......
    ............#.
    .#..#.......#.
    .#..#..#......
    .#..#..#......
    .#.....#......
    .#............
    .#######......
    ..........#...
    ....##.####...
    ....#.....#...
    ....#.....#...
    ....#.........
    ....#######...
    """

    expect = """
    ......+.......
    ......|.....#.
    .#..#.|.....#.
    .#..#.|#......
    .#..#.|#......
    .#....|#......
    .#|||||||.....
    .#######|.....
    ......||||#...
    ....##|####...
    ....#.|...#...
    ....#.|...#...
    ....#|||||||..
    ....#######|..
    """

    assert generate_water_flow(read_map(map)) == read_map(expect)
  end

  test "water flow up and down" do
    map = """
    ......+.......
    ..............
    ..............
    .#............
    .#.#.....#.#..
    .#.#.....#.#..
    .#.#.#.#.#.#..
    .#.#.###.#.#..
    .#.#.....#.#..
    .#.#######.#..
    .#.........#..
    .#.........#..
    .###########..
    .....#........
    """

    expect = """
    ......+.......
    ......|.......
    ......|.......
    .#|||||||||||.
    .#~#~~~~~#~#|.
    .#~#~~~~~#~#|.
    .#~#~#~#~#~#|.
    .#~#~###~#~#|.
    .#~#~~~~~#~#|.
    .#~#######~#|.
    .#~~~~~~~~~#|.
    .#~~~~~~~~~#|.
    .###########|.
    .....#......|.
    """

    assert generate_water_flow(read_map(map)) == read_map(expect)
  end

  test "water flow larger" do
    map = """
    ..................+........................
    ...........................................
    ...........................................
    ...........................................
    ...........................................
    ...........................................
    ............................#.#............
    ............................#.#............
    ............................#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........#.#......#.....
    .................#..........###......#.....
    .................#...................#.....
    .................#...................#.....
    .................#####################.....
    ...........................................
    ...........................................
    ...........................................
    ...........................................
    ...........................................
    ...........................................
    ....#.........................#............
    ....#.........................#............
    ....#.........................#............
    ....#.........................#............
    ....#.........................#............
    ....#.................###.....#............
    ....#.................#.#.....#............
    ....#.................#.#.....#............
    ....#.................###.....#............
    ....#.........................#............
    ....#.........................#............
    ....#.........................#............
    ....###########################............
    """

    expect = """
    ..................+........................
    ..................|........................
    ..................|........................
    ..................|........................
    ..................|........................
    ..................|........................
    ..................|.........#.#............
    ..................|.........#.#............
    ................||||||||||||#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~#.#......#.....
    ................|#~~~~~~~~~~###......#.....
    ................|#~~~~~~~~~~~~~~~~~~~#.....
    ................|#~~~~~~~~~~~~~~~~~~~#.....
    ................|#####################.....
    ................|..........................
    ................|..........................
    ................|..........................
    ................|..........................
    ................|..........................
    ...|||||||||||||||||||||||||||||...........
    ...|#~~~~~~~~~~~~~~~~~~~~~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~~~~~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~~~~~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~~~~~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~~~~~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~###~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~#.#~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~#.#~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~###~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~~~~~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~~~~~~~~~#|...........
    ...|#~~~~~~~~~~~~~~~~~~~~~~~~~#|...........
    ...|###########################|...........
    """

    assert generate_water_flow(read_map(map)) == read_map(expect)
  end

  test "count_tiles" do
    expect = """
    ......+.......
    ......|.....#.
    .#..#||||...#.
    .#..#~~#|.....
    .#..#~~#|.....
    .#~~~~~#|.....
    .#~~~~~#|.....
    .#######|.....
    ........|.....
    ...|||||||||..
    ...|#~~~~~#|..
    ...|#~~~~~#|..
    ...|#~~~~~#|..
    ...|#######|..
    """

    assert count_water_tiles(read_map(expect)) == 57
  end

  test "is_blocked? right" do
    map = """
    ......+.......
    ............#.
    .#..#.......#.
    .#..#..#......
    .#..#..#......
    .#.....#......
    .#.....#......
    .#######......
    ..............
    ..............
    ....#.....#...
    ....#.....#...
    ....#.....#...
    ....#######...
    """

    x = 500
    y = 6
    vx = 1
    vy = 0

    assert is_blocked?(read_map(map), {x, y}, {vx, vy}) == true
  end

  test "is_blocked? left" do
    map = """
    ......+.......
    ............#.
    .#..#.......#.
    .#..#..#......
    .#..#..#......
    .#.....#......
    .#.....#......
    .#######......
    ..............
    ..............
    ....#.....#...
    ....#.....#...
    ....#.....#...
    ....#######...
    """

    x = 500
    y = 6
    vx = -1
    vy = 0

    assert is_blocked?(read_map(map), {x, y}, {vx, vy}) == true
  end

  test "is_blocked? right, still_water" do
    map = """
    ......+.......
    ............#.
    .#..#.......#.
    .#..#..#......
    .#..#..#......
    .#.....#......
    .#~~~~~#......
    .#######......
    ..............
    ..............
    ....#.....#...
    ....#.....#...
    ....#.....#...
    ....#######...
    """

    x = 500
    y = 5
    vx = 1
    vy = 0

    assert is_blocked?(read_map(map), {x, y}, {vx, vy}) == true
  end

  test "is_blocked? left, still_water" do
    map = """
    ......+.......
    ............#.
    .#..#.......#.
    .#..#..#......
    .#..#..#......
    .#.....#......
    .#~~~~~#......
    .#######......
    ..............
    ..............
    ....#.....#...
    ....#.....#...
    ....#.....#...
    ....#######...
    """

    x = 500
    y = 5
    vx = -1
    vy = 0

    assert is_blocked?(read_map(map), {x, y}, {vx, vy}) == true
  end
end
