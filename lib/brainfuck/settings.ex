defmodule Brainfuck.Setting do
  use GenServer

  @settings %{
    "output" => "output",
    "save_folder" => "save_folder",
    "vis" => "visualizer",
    "speed" => "speed"
  }

  @values %{
    "text" => "text",
    "numbers" => "numbers",
    "on" => true,
    "off" => false
  }

  @config Application.compile_env!(:brainfuck, __MODULE__)

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_setting(setting) do
    case @settings[setting] do
      nil ->
        IO.inspect("Setting does not exist")
        :error

      atom ->
        GenServer.call(__MODULE__, {:get_setting, atom})
    end
  end

  def set_setting(setting, value) do
    case @settings[setting] do
      nil ->
        IO.inspect("Setting does not exist")
        :error

      atom ->
        value = if value in Map.keys(@values), do: @values[value], else: value
        GenServer.call(__MODULE__, {:set_setting, {atom, value}})
    end
  end

  @impl true
  def init(_init_arg) do
    with program_path <- File.cwd!(),
         save_folder <- program_path <> @config[:saved_programs_path],
         settings_path <- program_path <> @config[:settings],
         {:ok, json} <- File.read(settings_path),
         settings <- Jason.decode!(json),
         settings <-
           Map.merge(settings, %{"save_folder" => save_folder, "settings_path" => settings_path}) do
      {:ok, settings}
    else
      _ -> {:stop, ""}
    end
  end

  @impl true
  def handle_call({:set_setting, {setting, value}}, _from, state) do
    value =
      case setting do
        "speed" ->
          if String.match?(value, ~r/^[[:digit:]]+$/),
            do: String.to_integer(value),
            else: state[setting]

        "visualizer" ->
          if is_boolean(value), do: value, else: state[setting]

        _ ->
          value
      end

    state = Map.put(state, setting, value)
    settings_path = state["settings_path"]
    json = state |> Map.delete("settings_path") |> Jason.encode!()
    File.write(settings_path, json)

    {:reply, :ok, state}
  end

  def handle_call({:get_setting, setting}, _from, state) do
    reply =
      case Map.get(state, setting) do
        nil -> {:error, :not_set}
        value -> {:ok, value}
      end

    {:reply, reply, state}
  end
end
