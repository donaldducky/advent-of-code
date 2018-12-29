defmodule LineParser do
  import NimbleParsec

  defcombinatorp(
    :attack_type,
    choice([
      string("bludgeoning") |> replace(:bludgeoning),
      string("radiation") |> replace(:radiation),
      string("cold") |> replace(:cold),
      string("fire") |> replace(:fire),
      string("slashing") |> replace(:slashing)
    ])
    |> lookahead_not(ascii_char([?a..?z, ?A..?Z, ?0..?9]))
  )

  immunities =
    ignore(string("immune to "))
    |> times(
      parsec(:attack_type)
      |> unwrap_and_tag(:immune)
      |> optional(ignore(string(", "))),
      min: 1
    )

  weaknesses =
    ignore(string("weak to "))
    |> times(
      parsec(:attack_type)
      |> unwrap_and_tag(:weak)
      |> optional(ignore(string(", "))),
      min: 1
    )

  immunities_and_weaknesses =
    ignore(string("("))
    |> times(
      choice([
        immunities,
        weaknesses
      ])
      |> optional(ignore(string("; "))),
      min: 1
    )
    |> ignore(string(") "))

  # 4513 units each with 3901 hit points (weak to slashing; immune to
  # bludgeoning, radiation) with an attack that does 7 bludgeoning
  # damage at initiative 12
  line =
    unwrap_and_tag(integer(min: 1), :units)
    |> ignore(string(" units each with "))
    |> unwrap_and_tag(integer(min: 1), :hp)
    |> ignore(string(" hit points "))
    |> optional(immunities_and_weaknesses)
    |> ignore(string("with an attack that does "))
    |> unwrap_and_tag(integer(min: 1), :attack)
    |> ignore(string(" "))
    |> unwrap_and_tag(parsec(:attack_type), :attack_type)
    |> ignore(string(" damage at initiative "))
    |> unwrap_and_tag(integer(min: 1), :initiative)

  @doc """
  iex> LineParser.line("1166 units each with 7295 hit points with an attack that does 56 bludgeoning damage at initiative 8")
  {:ok, [{:units, 1166}, {:hp, 7295}, {:attack, 56}, {:attack_type, :bludgeoning}, {:initiative, 8}], "", %{}, {1, 0}, 99}

  iex> LineParser.line("498 units each with 2425 hit points (immune to fire, bludgeoning, cold) with an attack that does 44 slashing damage at initiative 3")
  {:ok, [{:units, 498}, {:hp, 2425}, {:immune, :fire}, {:immune, :bludgeoning}, {:immune, :cold}, {:attack, 44}, {:attack_type, :slashing}, {:initiative, 3}], "", %{}, {1, 0}, 131}

  iex> LineParser.line("1344 units each with 9093 hit points (immune to bludgeoning, cold; weak to radiation) with an attack that does 63 cold damage at initiative 16")
  {:ok, [{:units, 1344}, {:hp, 9093}, {:immune, :bludgeoning}, {:immune, :cold}, {:weak, :radiation}, {:attack, 63}, {:attack_type, :cold}, {:initiative, 16}], "", %{}, {1, 0}, 142}

  iex> LineParser.line("700 units each with 47055 hit points (weak to fire; immune to slashing) with an attack that does 116 fire damage at initiative 14")
  {:ok, [{:units, 700}, {:hp, 47055}, {:weak, :fire}, {:immune, :slashing}, {:attack, 116}, {:attack_type, :fire}, {:initiative, 14}], "", %{}, {1, 0}, 129}
  """
  defparsec(:line, line)
end
