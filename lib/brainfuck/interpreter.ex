defmodule Brainfuck.Interpreter do
  @tape [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @valid_input ~r/^[+-<>.,\[\]]+$/

  def run(program) do
    if String.match?(program, @valid_input) do
      execute_program(program)
    else
      IO.puts("INVALID INPUT")
    end
  end

  defp execute_program(program) do
    tape = @tape
    pointer = 0
    instructions = String.graphemes(program)
    IO.puts("Output:")

    Enum.reduce(instructions, {tape, pointer}, fn ins, {t, p} ->
      execute_instruction(ins, t, p)
    end)
  end

  defp execute_instruction(ins, tape, pointer) do
    case ins do
      "+" ->
        curr = Enum.at(tape, pointer)
        tape = List.replace_at(tape, pointer, curr + 1)
        {tape, pointer}

      "-" ->
        curr = Enum.at(tape, pointer)
        tape = List.replace_at(tape, pointer, curr - 1)
        {tape, pointer}

      "<" ->
        {tape, pointer - 1}

      ">" ->
        {tape, pointer + 1}

      "." ->
        Enum.at(tape, pointer)
        |> to_print()
        |> IO.inspect(syntax_colors: [number: :blue, string: :green])

        {tape, pointer}

      "," ->
        number =
          IO.gets("Input number: ")
          |> String.trim()
          |> String.to_integer()

        tape = List.replace_at(tape, pointer, number)
        {tape, pointer}
    end
  end

  defp to_print(number) do
    if List.ascii_printable?([number]) do
      to_string([number])
    else
      number
    end
  end
end
