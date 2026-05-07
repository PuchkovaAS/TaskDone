defmodule WorkReport do
  @moduledoc """
  # Analyze report file and gather work statistics
  """
  alias DialyxirVendored.Formatter
  alias WorkReport.Model.ReportTypedStruct, as: M
  alias WorkReport.Parser
  alias WorkReport.Formatter

  @name "Work Report"
  @version "1.0.0"

  @spec main([String.t()]) :: :ok
  def main(args) do
    case OptionParser.parse(args, options()) do
      {[help: true], [], []} -> help()
      {[version: true], [], []} -> version()
      {params, [file], []} -> do_report(Map.new(params), file)
      _ -> help()
    end
  end

  def options do
    [
      strict: [day: :integer, month: :integer, version: :boolean, help: :boolean],
      aliases: [d: :day, m: :month, v: :version, h: :help]
    ]
  end

  def do_report(params, file) do
    month = Map.get(params, :month, :erlang.date() |> elem(1))
    day = Map.get(params, :day, :erlang.date() |> elem(2))
    {:ok, month_list} = Parser.parse_report(file)

    with {:ok, report_month} <- find_month(month, month_list),
         {:ok, report_day} <- find_day(day, report_month.days) do
      IO.puts(Formatter.format_responce(report_day, report_month))
    else
      {:error, :not_found_month} ->
        IO.inspect("Month #{month} is not found")

      {:error, :not_found_day} ->
        IO.inspect("Day #{day} is not found in month #{month}")

      other ->
        IO.inspect("Неожиданная ошибка #{other}")
    end
  end

  def help() do
    IO.puts("""
    USAGE:
        work_report [OPTIONS] <path/to/report.md>
    OPTIONS:
        -m, --month <M>  Show report for month (int), current month by default
        -d, --day <D>    Show report for day (int), current day by default
        -v, --version    Show version
        -h, --help       Show this help message
    """)
  end

  def version() do
    IO.puts(@name <> " v" <> @version)
  end

  defp find_month(month_num, months_list) do
    case Enum.find(months_list, fn %M.MonthReport{month_ind: m} -> m == month_num end) do
      nil -> {:error, :not_found_month}
      found -> {:ok, found}
    end
  end

  defp find_day(day_num, day_list) do
    case Enum.find(day_list, fn %M.Day{num: d} ->
           case Integer.parse(to_string(d)) do
             {parsed, ""} -> parsed == day_num
             _ -> false
           end
         end) do
      nil -> {:error, :not_found_day}
      found -> {:ok, found}
    end
  end
end
