defmodule Brainfuck.Setting do
  use GenServer

  @settings %{
    "output_type" => :output_type
  }

  @values %{
    "text" => :text,
    "numbers" => :numbers
  }

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
        value = @values[value]
        GenServer.call(__MODULE__, {:set_setting, {atom, value}})
    end
  end

  @impl true
  def init(_init_arg) do
    {:ok, %{output_type: :text}}
  end

  @impl true
  def handle_call({:set_setting, {setting, value}}, _from, state) do
    state = Map.put(state, setting, value)

    {:reply, :ok, state}
  end

  def handle_call({:get_setting, setting}, _from, state) do
    value = Map.get(state, setting)

    {:reply, value, state}
  end
end
