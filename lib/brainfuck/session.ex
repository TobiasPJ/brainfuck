defmodule Brainfuck.Session do
  use GenServer

  alias IO.ANSI

  @prompt ANSI.cyan() <> "brainfuck>>> " <> ANSI.reset()

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    IO.puts(
      "Type )help for help, )settings to see avalible settings and )commands to see avalible commands"
    )

    call()

    {:ok, %{}}
  end

  @impl true
  def handle_info(:get_input, state) do
    IO.write(@prompt)
    input = IO.gets("") |> format_string()

    case input do
      ")" <> command ->
        Brainfuck.Commands.run(command)

      "]" <> setting ->
        IO.inspect(call_setting(setting), syntax_colors: [atom: :blue])

      "run" <> file_path ->
        Brainfuck.Commands.run("run", file_path)

      "edit" <> file_path ->
        Brainfuck.Commands.run("edit", file_path)

      "p" <> number ->
        Brainfuck.Commands.run("p", number)

      _ ->
        Brainfuck.Interpreter.run(input)
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

  defp format_string(input) do
    input
    |> String.trim()
    |> String.replace("\n", "")
    |> String.replace(" ", "")
  end
end
