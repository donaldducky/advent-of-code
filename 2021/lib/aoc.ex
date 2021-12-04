defmodule Aoc do
  @moduledoc """
  Documentation for `Aoc`.
  """

  @doc """
  Download input.
  """
  def get_input(day, year \\ 2021) when is_integer(day) and is_integer(year) do
    input = "priv/#{year}-#{String.pad_leading("#{day}", 2, "0")}.in"

    if File.exists?(input) do
      File.read!(input)
    else
      session =
        System.get_env("AOC_SESSION") ||
          raise """
          AOC_SESSION env var not set
          Log into https://adventofcode.com and get the value of the session cookie and export it.

            ```
            export AOC_SESSION="<cookie-value>"
            make livebook
            ```
          """

      opts = [
        headers: [
          {"cookie", "session=#{session}"}
        ]
      ]

      case Req.get!("https://adventofcode.com/#{year}/day/#{day}/input", opts) do
        %{status: 200, body: body} ->
          File.write!(input, body)
          body

        res ->
          res |> IO.inspect(label: "Could not fetch input for #{year} day #{day}")
          ""
      end
    end
  end
end
