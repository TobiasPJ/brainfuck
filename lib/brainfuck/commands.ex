defmodule Brainfuck.Commands do
  def run(command) do
    case String.downcase(command) do
      ")help" -> render_info()
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
end
