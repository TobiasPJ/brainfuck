defmodule Brainfuck.Commands do
  alias TableRex.Table

  def run(command) do
    case String.downcase(command) do
      "help" -> render_info()
      "save" -> save_program()
      "saved" -> display_saved_programs()
      _ -> IO.puts("Unknown command")
    end
  end

  def run(command, value) do
    case command do
      "run" -> run_program(value)
      "edit" -> edit_program(value)
      _ -> IO.puts("Unknown command")
    end
  end

  defp render_info do
    title = "How to Brainfuck"
    header = ["Instruction", "Description"]

    rows = [
      ["+", "Adds one to the current cell"],
      ["-", "Subtracts one from the current cell"],
      [">", "Moves one cell to the right"],
      ["<", "Moves one cell to the left"],
      [".", "Outputs the value of the current cell"],
      [",", "Accepts input from user and puts it into the current cell"],
      ["[", "Start of a loop"],
      [
        "]",
        "If the value of the current cell is 0, the next instruction will execute, else jump to the beginning of the loop"
      ]
    ]

    TableRex.quick_render!(rows, header, title) |> IO.puts()
  end

  defp run_program(file_name) do
    with {:ok, path} <- get_path(file_name),
         {:ok, data} <- File.read(path) do
      data
      |> format_string()
      |> Brainfuck.Interpreter.run()
    else
      {:error, error} ->
        IO.puts(:file.format_error(error))
    end
  end

  defp edit_program(file_name) do
    with {:ok, path} <- get_path(file_name),
         true <- File.exists?(path) do
      System.cmd("open", ["-t", path])
    else
      {:error, error} ->
        IO.puts(:file.format_error(error))

      false ->
        IO.puts("This file does not exist")
    end
  end

  defp save_program do
    case Brainfuck.History.get_latest_program() do
      {:ok, latest_program} ->
        case IO.gets("Name for file: ") do
          :eof ->
            IO.puts("End of file")

          {:error, _} ->
            IO.puts("Error on input")

          name ->
            name = format_string(name)

            case get_path(name) do
              {:ok, file_path} ->
                :ok = File.write(file_path, latest_program)

              _ ->
                :ok
            end
        end

      {:error, :no_history} ->
        IO.puts("There was no history to save")
    end
  end

  defp get_path(name) do
    with false <- File.exists?(name),
         {:ok, path} <- Brainfuck.Setting.get_setting("save_folder"),
         file_path <- Path.join(path, "/" <> name <> ".bf") do
      {:ok, file_path}
    else
      true ->
        {:ok, name}

      _ ->
        IO.puts("No save path has been set use ]save_folder to set")
        {:error, :badarg}
    end
  end

  defp display_saved_programs do
    with {:ok, path} <- Brainfuck.Setting.get_setting("save_folder"),
         {:ok, file_names} <- File.ls(path),
         rows <- Enum.map(file_names, &[&1]) do
      Table.new(rows)
      |> Table.put_title("Saved files")
      |> Table.put_column_meta(0, color: :magenta)
      |> Table.render!()
      |> IO.puts()
    else
      {:error, _} -> IO.puts("Error while trying to get files")
    end
  end

  defp format_string(input) do
    input
    |> String.trim()
    |> String.replace("\n", "")
    |> String.replace(" ", "")
  end
end
