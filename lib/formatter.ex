defmodule WorkReport.Formatter do
  alias WorkReport.Model.ReportTypedStruct, as: M

  @spec format_time(integer) :: String.t()
  def format_time(time_minutes) do
    hours = div(time_minutes, 60)
    minutes = rem(time_minutes, 60)

    cond do
      hours > 0 and minutes > 0 -> "#{hours}h #{minutes}m"
      hours > 0 -> "#{hours}h"
      minutes > 0 -> "#{minutes}m"
      true -> "0"
    end
  end

  @spec format_responce(M.Day, M.MonthReport) :: String.t()
  def format_responce(day_report, month_report) do
    list_report = []

    string_report = add_task_to_responce(day_report.tasks, list_report, 0)

    list_report = [string_report | list_report]
    list_report = ["Day: #{day_report.num} #{day_report.weekday}\n" | list_report]

    day_stat =
      list_report
      |> Enum.join("\n")

    tasks_stat = format_month_responce(month_report)
    list_report = ["\nMonth: #{month_report.month_name}\n", day_stat]

    list_report =
      [tasks_stat | list_report]

    list_report
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  @spec add_task_to_responce([M.Task], [String.t()], non_neg_integer()) :: String.t()
  defp add_task_to_responce([task | tasks], list_report, total_time) do
    new_task = "- #{task.type}: #{task.desc} - #{format_time(task.time_minutes)}"

    add_task_to_responce(tasks, [new_task | list_report], total_time + task.time_minutes)
  end

  defp add_task_to_responce([], list_report, total_time) do
    list_report = Enum.join(list_report, "\n")

    list_report <> "\n  Total: #{format_time(total_time)}"
  end

  # TODO total_responce for month

  @spec format_month_responce(M.MonthReport) :: String.t()
  def format_month_responce(month) do
    task_map = %{
      "COMM" => 0,
      "DEV" => 0,
      "DOC" => 0,
      "EDU" => 0,
      "OPS" => 0,
      "WS" => 0
    }

    cnt_days = 0
    {task_map, cnt_days} = add_day_to_month_response(month.days, task_map, cnt_days)

    total_time = Enum.reduce(task_map, 0, fn {_key, time_minutes}, acc -> acc + time_minutes end)

    response =
      task_map
      |> Enum.map(fn {type, time_minutes} -> "- #{type}: #{format_time(time_minutes)}" end)
      |> Enum.join("\n")

    response <>
      "\n  Total: #{format_time(total_time)}, Days: #{cnt_days}, Avg: #{format_time(div(total_time, cnt_days))}"
  end

  @spec add_day_to_month_response([M.Day], map(), Integer.t()) :: {map(), Integer.t()}
  defp add_day_to_month_response([day | days], task_map, cnt_days) do
    task_map = add_task_from_day_to_month_response(day.tasks, task_map)
    add_day_to_month_response(days, task_map, cnt_days + 1)
  end

  defp add_day_to_month_response([], task_map, cnt_days) do
    {task_map, cnt_days}
  end

  @spec add_task_from_day_to_month_response([M.Task], map()) :: map()
  defp add_task_from_day_to_month_response([task | tasks], task_map) do
    time_type = Map.get(task_map, task.type, 0)
    task_map = Map.put(task_map, task.type, time_type + task.time_minutes)
    add_task_from_day_to_month_response(tasks, task_map)
  end

  defp add_task_from_day_to_month_response([], task_map) do
    task_map
  end
end
