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

  @spec format_responce(M.Day) :: String.t()
  def format_responce(day_report) do
    list_report = ["Day: #{day_report.num} #{day_report.weekday} \n"]

    add_task_to_responce(day_report.tasks, list_report, 0)
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  @spec add_task_to_responce([M.Task], [String.t()], non_neg_integer()) :: [String.t()]
  defp add_task_to_responce([task | tasks], list_report, total_time) do
    new_task = " - #{task.type}: #{task.desc} - #{format_time(task.time_minutes)}"
    add_task_to_responce(tasks, [new_task | list_report], total_time + task.time_minutes)
  end

  defp add_task_to_responce([], list_report, total_time) do
    ["Total: #{format_time(total_time)}" | list_report]
  end

  # TODO total_responce for month
end
