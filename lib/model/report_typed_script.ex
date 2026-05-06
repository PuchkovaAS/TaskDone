defmodule WorkReport.Model.ReportTypedStruct do
  defmodule Task do
    @type t() :: %__MODULE__{
            type: String.t(),
            desc: String.t(),
            time_minutes: non_neg_integer()
          }
    @enforce_keys [:type, :desc, :time_minutes]
    defstruct [:type, :desc, :time_minutes]

    def new(type, desc, time_minutes)
        when is_binary(type) and is_binary(desc) and is_integer(time_minutes) do
      {:ok,
       %__MODULE__{
         type: String.capitalize(type),
         desc: String.trim(desc),
         time_minutes: time_minutes
       }}
    end
  end

  defmodule Day do
    @type t() :: %__MODULE__{
            num: 1..31,
            weekday: String.t(),
            tasks: [Task.t()]
          }
    @enforce_keys [:num, :weekday]
    defstruct [:num, :weekday, tasks: []]

    def new(num, weekday) when is_binary(num) and is_binary(weekday) do
      {:ok,
       %__MODULE__{
         num: String.to_integer(num),
         weekday: String.trim(weekday)
       }}
    end

    def add_task(day, task_params) do
      case Task.new(task_params.type, task_params.desc, task_params.time_minutes) do
        {:ok, task} -> {:ok, %{day | tasks: [task | day.tasks]}}
        {:error, _} -> {:error, :invalid_task}
      end
    end
  end

  defmodule MonthReport do
    @type t() :: %__MODULE__{
            month_name: String.t(),
            month_ind: 1..12,
            days: [Day.t()]
          }
    @enforce_keys [:month_name]
    defstruct [:month_name, days: [], month_ind: 0]

    @months %{
      "January" => 1,
      "February" => 2,
      "March" => 3,
      "April" => 4,
      "May" => 5,
      "June" => 6,
      "July" => 7,
      "August" => 8,
      "September" => 9,
      "October" => 10,
      "November" => 11,
      "December" => 12
    }

    def new(month_name) when is_binary(month_name) do
      case parse_month_index(month_name) do
        0 -> {:error, "Unknown month: #{month_name}"}
        idx -> {:ok, %__MODULE__{month_name: String.capitalize(month_name), month_ind: idx}}
      end
    end

    def add_day(month, %{num_day: num_day, weekday: weekday}) do
      case Day.new(num_day, weekday) do
        {:ok, day} -> {:ok, %{month | days: [day | month.days]}}
        {:error, _} -> {:error, :invalid_day}
      end
    end

    def add_task(%__MODULE__{days: []} = _month, _), do: {:error, :no_active_day}

    def add_task(month, task_params) do
      [latest_day | rest_days] = month.days

      case Day.add_task(latest_day, task_params) do
        {:ok, updated_day} -> {:ok, %{month | days: [updated_day | rest_days]}}
        err -> err
      end
    end

    defp parse_month_index(name) do
      Map.get(@months, String.capitalize(String.trim(name)), 0)
    end
  end
end
