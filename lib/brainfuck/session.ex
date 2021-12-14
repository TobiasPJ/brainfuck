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
      <<?), command::binary>> ->
        Brainfuck.Commands.run(command)

      <<?], setting::binary>> ->
        IO.inspect(call_setting(setting), syntax_colors: [atom: :blue])

      _ ->
        Brainfuck.Interpreter.run(program)
    end

    call()
    {:noreply, state}
  end

  defp call do
    Process.send(self(), :get_input, [:noconnect])
  end

  defp call_setting(setting) do
    case String.split(setting, "=") do
      [setting] -> Brainfuck.Setting.get_setting(setting)
      [setting, value] -> Brainfuck.Setting.set_setting(setting, value)
    end
  end
end
