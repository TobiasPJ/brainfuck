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
    ob = []
    IO.puts("Output:")

    :done = execute_instruction(instructions, tape, pointer, ls, ci, ob)
  end

  defp execute_instruction(instructions, tape, pointer, ls, ci, ob) do
    if ci >= length(instructions) do
      if !Enum.empty?(ls) do
        Logger.warn("Loop starting at position #{hd(ls)} was never closed")
      end

      case Brainfuck.Setting.get_setting("output_type") do
        :text ->
          ob |> Enum.join() |> IO.inspect(syntax_colors: [string: :green])
          :done

        :numbers ->
          Enum.each(ob, fn n ->
            IO.write(n)
            IO.write(" ")
          end)

          :done

        _ ->
          :done
      end
    else
      ins = Enum.at(instructions, ci)

      case ins do
        "+" ->
          curr = Enum.at(tape, pointer)
          tape = List.replace_at(tape, pointer, curr + 1)
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob)

        "-" ->
          curr = Enum.at(tape, pointer)
          tape = List.replace_at(tape, pointer, curr - 1)
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob)

        "<" ->
          execute_instruction(instructions, tape, pointer - 1, ls, ci + 1, ob)

        ">" ->
          execute_instruction(instructions, tape, pointer + 1, ls, ci + 1, ob)

        "." ->
          ob = ob ++ to_print(Enum.at(tape, pointer))
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob)

        "," ->
          number =
            IO.gets("Input number: ")
            |> String.trim()
            |> String.to_integer()

          tape = List.replace_at(tape, pointer, number)
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob)

        "[" ->
          # TODO the loop should not start if the value at pointer is 0
          # instead it should jump to the end of the loop
          ls = [ci | ls]
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob)

        "]" ->
          if Enum.at(tape, pointer) == 0 do
            ls = List.delete_at(ls, 0)
            execute_instruction(instructions, tape, pointer, ls, ci + 1, ob)
          else
            loop_start = hd(ls)
            execute_instruction(instructions, tape, pointer, ls, loop_start + 1, ob)
          end
      end
    end
  end

  defp to_print(number) do
    case Brainfuck.Setting.get_setting("output_type") do
      :text ->
        [to_string([number])]

      :numbers ->
        [number]

      _ ->
        IO.inspect("Incorrect output type", syntax_colors: [string: :red])
        []
    end
  end
end
