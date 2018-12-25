defmodule LineParser do
  import NimbleParsec

  instruction_pointer =
    ignore(string("#ip "))
    |> integer(min: 1)

  op =
    choice([
      string("addr"),
      string("addi"),
      string("mulr"),
      string("muli"),
      string("banr"),
      string("bani"),
      string("borr"),
      string("bori"),
      string("setr"),
      string("seti"),
      string("gtir"),
      string("gtri"),
      string("gtrr"),
      string("eqir"),
      string("eqri"),
      string("eqrr")
    ])

  instruction =
    op
    |> ignore(string(" "))
    |> integer(min: 1)
    |> ignore(string(" "))
    |> integer(min: 1)
    |> ignore(string(" "))
    |> integer(min: 1)

  line =
    choice([
      instruction_pointer,
      instruction
    ])

  defparsec(:line, line)
end
