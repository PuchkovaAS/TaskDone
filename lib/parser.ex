defmodule WorkReport.Parser do
  alias WorkReport.Model.ReportTypedStruct, as: R

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
            new_months =
              if state.current,
                do: [state.current | state.months],
                else: state.months

            %{state | months: new_months, current: new_month}

          {:error, _error} ->
            state
        end

      String.starts_with?(line, "## ") ->
        [num_day, weekday] = line |> String.trim_leading("## ") |> String.split()

        if state.current do
          case R.MonthReport.add_day(state.current, %{num_day: num_day, weekday: weekday}) do
            {:ok, updated_month} ->
              %{state | current: updated_month}

            {:error, _error} ->
              state
          end
        else
          state
        end

      String.starts_with?(line, "[") ->
        [type_desc, time] = line |> String.trim_leading("[") |> String.split(" - ")
        [type, desc] = type_desc |> String.split("] ")

        if state.current do
          case R.MonthReport.add_task(state.current.months, %{type: type, desc: desc, time: time}) do
            {:ok, day} ->
              state.current.
              %{state | current: updated_month}

            {:error, _error} ->
              state
          end
        else
          state
        end

      true ->
        state
    end
  end
end
