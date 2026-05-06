defmodule WorkReport.Model.ReportTypedStruct do
  defmodule Task do
    @type t() :: %__MODULE__{
            type: String.t(),
            desc: String.t(),
            time: String.t()
          }
    @enforce_keys [:title]
    defstruct [
      :type,
      :desc,
      :time
    ]

    def new(type, desc, time) when is_binary(type) and is_binary(desc) and is_binary(time) do
      {:ok,
       %__MODULE__{
         type: String.capitalize(type),
         desc: desc,
         time: time
       }}
    end
  end

  defmodule Day do
    @type t() :: %__MODULE__{
            num: [1..31],
            weekday: String.t()
          }
    @enforce_keys [:num, :weekday]
    defstruct [:num, :weekday]

    @spec new(String.t(), String.t()) :: {:ok, t()} | {:error, String.t()}
    def new(num, weekday) when is_binary(num) and is_binary(weekday) do
      {:ok,
       %__MODULE__{
         num: String.to_integer(num),
         weekday: weekday
       }}
    end
  end

  defmodule Event do
    @type t() :: %__MODULE__{
            title: String.t(),
            place: Place.t(),
            time: Time.t(),
            participants: list(Participant.t()),
            agenda: [Topic.t()]
          }
    @enforce_keys [:title, :place, :time]
    defstruct [
      :title,
      :place,
      :time,
      {:participants, []},
      {:agenda, []}
    ]
  end

  defmodule MonthReport do
    @type t() :: %__MODULE__{
            month_name: String.t(),
            month_ind: 0..12,
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

    @spec new(String.t()) :: {:ok, t()} | {:error, String.t()}
    def new(month_name) when is_binary(month_name) do
      case parse_month_index(month_name) do
        0 ->
          {:error, "Unknown month: #{month_name}"}

        idx ->
          {:ok,
           %__MODULE__{
             month_name: String.capitalize(month_name),
             month_ind: idx
           }}
      end
    end

    def add_day(month, %{num_day: num_day, weekday: weekday}) do
      case Day.new(num_day, weekday) do
        {:ok, day} ->
          {:ok, %{month | days: [day | month.days]}}

        {:error, error} ->
          {:error, error}
      end
    end

    def add_task(day, %{type: type, desc: desc, time: time}) do
      case Task.new(type, desc, time) do
        {:ok, task} ->
          {:ok, %{day | tasks: [task | day.tasks]}}

        {:error, error} ->
          {:error, error}
      end
    end

    defp parse_month_index(name) do
      Map.get(@months, String.capitalize(String.trim(name)), 0)
    end
  end
end
