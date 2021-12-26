defmodule Brainfuck.History do
  use GenServer

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def get_latest_program do
    GenServer.call(__MODULE__, :get_latest_program)
  end

  def get_program(number) do
    GenServer.call(__MODULE__, {:get_program, number})
  end

  def add_program(program) do
    GenServer.cast(__MODULE__, {:add_program, program})
  end

  @impl true
  def init(_init_arg) do
    state = %{latest_programs: []}

    {:ok, state}
  end

  @impl true
  def handle_call(:get_latest_program, _from, state) do
    reply =
      case state[:latest_programs] do
        [head | _] -> head
        _ -> :no_history
      end

    {:reply, reply, state}
  end

  def handle_call({:get_program, number}, _from, state) do
    reply =
      case Enum.at(state[:latest_programs], number) do
        nil -> :NA
        program -> program
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:add_program, program}, state) do
    current_history = state[:latest_programs]
    state = %{state | latest_programs: [program | current_history]}
    {:noreply, state}
  end
end
