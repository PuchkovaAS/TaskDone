defmodule WorkReport.Parser do
  alias WorkReport.Model.ReportTypedStruct, as: R

  @spec parse_time(String.t()) :: non_neg_integer()
  def parse_time(time_str) do
    time_str = String.trim(time_str)

    case String.split(time_str, " ", parts: 2) do
      [h_part, m_part] ->
        hours = String.trim_trailing(h_part, "h") |> String.to_integer()
        mins = String.trim_trailing(m_part, "m") |> String.to_integer()
        hours * 60 + mins

      [m_part] ->
        String.trim_trailing(m_part, "m") |> String.to_integer()

      _ ->
        0
    end
  end

  def parse_report(file_path) do
    final_state =
      File.stream!(file_path)
      |> Stream.map(&String.trim/1)
      |> Stream.reject(&(&1 == ""))
      |> Enum.reduce(%{months: [], current: nil}, &process_line/2)

    months =
      if final_state.current do
        [final_state.current | final_state.months]
      else
        final_state.months
      end

    {:ok, Enum.reverse(months)}
  end

  defp process_line(line, state) do
    cond do
      String.starts_with?(line, "# ") ->
        month_name = String.trim_leading(line, "# ") |> String.trim()

        case R.MonthReport.new(month_name) do
          {:ok, new_month} ->
            new_months = if state.current, do: [state.current | state.months], else: state.months
            %{state | months: new_months, current: new_month}

          {:error, _} ->
            state
        end

      String.starts_with?(line, "## ") ->
        [num_day, weekday] = line |> String.trim_leading("## ") |> String.split()

        if state.current do
          case R.MonthReport.add_day(state.current, %{num_day: num_day, weekday: weekday}) do
            {:ok, updated_month} -> %{state | current: updated_month}
            {:error, _} -> state
          end
        else
          state
        end

      String.starts_with?(line, "[") ->
        with [left_part, time_str] <- String.split(line, " - ", parts: 2),
             [type, desc] <- String.split(String.trim_leading(left_part, "["), "]", parts: 2) do
          task_params = %{
            type: String.trim(type),
            desc: String.trim(desc),
            time_minutes: parse_time(time_str)
          }

          if state.current do
            case R.MonthReport.add_task(state.current, task_params) do
              {:ok, updated_month} -> %{state | current: updated_month}
              {:error, _} -> state
            end
          else
            state
          end
        else
          _ -> state
        end

      true ->
        state
    end
  end
end
