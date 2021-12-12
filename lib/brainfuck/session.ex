defmodule Brainfuck.Session do
  use GenServer

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    call()

    {:ok, %{}}
  end

  @impl true
  def handle_info(:get_input, state) do
    program = IO.gets("\nAwaiting input\n\n") |> String.trim()

    case program do
      "quit" ->
        {:stop, :shutdown, state}

      _ ->
        Brainfuck.Interpreter.run(program)

        call()
        {:noreply, state}
    end
  end

  defp call do
    Process.send(self(), :get_input, [:noconnect])
  end
end
