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
    |> String.split("\n", trim: true)
  end

  def pretty(input) do
    count = Enum.count(input)

    input
    |> Enum.with_index()
    |> Enum.map(fn {line, i} ->
      "<tr><td style='width: 30px; border-right: 1px solid rgb(225, 232, 240);'>#{i}</td><td>#{line}</td></tr>"
    end)
    |> then(fn body ->
      [
        "Lines: #{count}",
        "<div style='overflow-y: scroll; height: 300px;'>",
        "<table><thead><tr><th>#</th><th>line</th></tr></thead>",
        "<tbody>#{body}</tbody></table>",
        "</div>"
      ]
      |> Enum.join()
    end)
    |> Kino.Markdown.new()
  end
end
