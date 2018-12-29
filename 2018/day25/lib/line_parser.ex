defmodule LineParser do
  import NimbleParsec

  pos_or_neg_integer =
    choice([
      ignore(string("-")) |> integer(min: 1) |> unwrap_and_tag(:negative),
      integer(min: 1) |> unwrap_and_tag(:positive)
    ])

  line = times(pos_or_neg_integer |> optional(ignore(string(","))), 4)

  defparsec(:line, line)
end
