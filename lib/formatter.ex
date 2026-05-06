defmodule WorkReport.Formatter do
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
end
