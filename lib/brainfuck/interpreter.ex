defmodule Brainfuck.Interpreter do
  require Logger
  @tape [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @loop_stack []
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
    ls = @loop_stack
    pointer = 0
    ci = 0
    instructions = String.graphemes(program)
    IO.puts("Output:")

    :done = execute_instruction(instructions, tape, pointer, ls, ci)
  end

  defp execute_instruction(instructions, tape, pointer, ls, ci) do
    if ci >= length(instructions) do
      if !Enum.empty?(ls) do
        Logger.warn("Loop starting at position #{hd(ls)} was never closed")
      end

      :done
    else
      ins = Enum.at(instructions, ci)

      case ins do
        "+" ->
          curr = Enum.at(tape, pointer)
          tape = List.replace_at(tape, pointer, curr + 1)
          execute_instruction(instructions, tape, pointer, ls, ci + 1)

        "-" ->
          curr = Enum.at(tape, pointer)
          tape = List.replace_at(tape, pointer, curr - 1)
          execute_instruction(instructions, tape, pointer, ls, ci + 1)

        "<" ->
          execute_instruction(instructions, tape, pointer - 1, ls, ci + 1)

        ">" ->
          execute_instruction(instructions, tape, pointer + 1, ls, ci + 1)

        "." ->
          Enum.at(tape, pointer)
          |> to_print()
          |> IO.inspect(syntax_colors: [number: :blue, string: :green])

          execute_instruction(instructions, tape, pointer, ls, ci + 1)

        "," ->
          number =
            IO.gets("Input number: ")
            |> String.trim()
            |> String.to_integer()

          tape = List.replace_at(tape, pointer, number)
          execute_instruction(instructions, tape, pointer, ls, ci + 1)

        "[" ->
          # TODO the loop should not start if the value at pointer is 0
          # instead it should jump to the end of the loop
          ls = [ci | ls]
          execute_instruction(instructions, tape, pointer, ls, ci + 1)

        "]" ->
          if Enum.at(tape, pointer) == 0 do
            ls = List.delete_at(ls, 0)
            execute_instruction(instructions, tape, pointer, ls, ci + 1)
          else
            loop_start = hd(ls)
            execute_instruction(instructions, tape, pointer, ls, loop_start + 1)
          end
      end
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
