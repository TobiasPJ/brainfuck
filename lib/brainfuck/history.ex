defmodule Brainfuck.History do
  use GenServer

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_latest_program do
    GenServer.call(__MODULE__, :get_latest_input)
  end

  def set_latest_program(program) do
    GenServer.cast(__MODULE__, {:set_latest_program, program})
  end

  @impl true
  def init(_init_arg) do
    state = %{latest_input: nil}

    {:ok, state}
  end

  @impl true
  def handle_call(:get_latest_input, _from, state) do
    input = state[:latest_input]

    reply =
      case input do
        nil -> {:error, :no_history}
        _ -> {:ok, input}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:set_latest_program, program}, state) do
    state = %{state | latest_input: program}
    {:noreply, state}
  end
end
