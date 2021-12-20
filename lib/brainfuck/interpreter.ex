defmodule Brainfuck.Interpreter do
  require Logger
  alias TableRex.Table
  alias Brainfuck.Setting

  @tape [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  @valid_input ~r/^[+-<>.,\[\]]+$/
  @cursor_move 6
  @tape_length length(@tape)

  def run(program) do
    if String.match?(program, @valid_input) do
      execute_program(program)
      Brainfuck.History.set_latest_program(program)
      :ok
    else
      IO.puts("INVALID INPUT")
      :error
    end
  end

  defp execute_program(program) do
    tape = @tape
    ls = []
    pointer = 0
    ci = 0
    instructions = String.graphemes(program)
    ob = []

    {:ok, visualize} = Setting.get_setting("vis")

    {:ok, speed} = Setting.get_setting("speed")

    :done =
      execute_instruction(instructions, tape, pointer, ls, ci, ob,
        visualize: visualize,
        speed: speed
      )
  end

  defp execute_instruction(instructions, tape, pointer, ls, ci, ob, opts) do
    if opts[:visualize], do: visualize_tape(tape, pointer, opts[:speed], ob)

    if ci >= length(instructions) do
      write_output(ob, ls)
    else
      ins = Enum.at(instructions, ci)

      case ins do
        "+" ->
          curr = Enum.at(tape, pointer)
          tape = List.replace_at(tape, pointer, curr + 1)
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob, opts)

        "-" ->
          curr = Enum.at(tape, pointer)
          tape = List.replace_at(tape, pointer, curr - 1)
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob, opts)

        "<" ->
          execute_instruction(instructions, tape, pointer - 1, ls, ci + 1, ob, opts)

        ">" ->
          execute_instruction(instructions, tape, pointer + 1, ls, ci + 1, ob, opts)

        "." ->
          ob = ob ++ to_print(Enum.at(tape, pointer))
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob, opts)

        "," ->
          number =
            IO.gets("Input number: ")
            |> String.trim()
            |> String.to_integer()

          tape = List.replace_at(tape, pointer, number)
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob, opts)

        "[" ->
          # TODO the loop should not start if the value at pointer is 0
          # instead it should jump to the end of the loop
          ls = [ci | ls]
          execute_instruction(instructions, tape, pointer, ls, ci + 1, ob, opts)

        "]" ->
          if Enum.at(tape, pointer) == 0 do
            ls = List.delete_at(ls, 0)
            execute_instruction(instructions, tape, pointer, ls, ci + 1, ob, opts)
          else
            try do
              loop_start = hd(ls)
              execute_instruction(instructions, tape, pointer, ls, loop_start + 1, ob, opts)
            rescue
              ArgumentError ->
                Logger.error("The loop ended at #{ci} was never started")
                execute_instruction(instructions, tape, pointer, ls, ci + 1, ob, opts)
            end
          end
      end
    end
  end

  defp write_output(ob, ls) do
    if !Enum.empty?(ls) do
      Logger.warn("Loop starting at position #{hd(ls)} was never closed")
    end

    IO.write(IO.ANSI.cursor_down(@cursor_move) <> "\nOutput: ")

    case Setting.get_setting("output") do
      {:ok, "text"} ->
        ob |> Enum.join() |> IO.inspect(syntax_colors: [string: :green])
        :done

      {:ok, "numbers"} ->
        Enum.each(ob, fn n ->
          IO.write(n)
          IO.write(" ")
        end)

        IO.puts("")
        :done

      _ ->
        :done
    end
  end

  defp visualize_tape(tape, pointer, speed, ob) do
    at =
      String.pad_leading("\u2193", pointer + 1)
      |> String.pad_trailing(@tape_length - pointer)
      |> String.graphemes()

    Table.new([tape])
    |> Table.put_header(at)
    |> Table.render!()
    |> Kernel.<>("Current output: #{ob}")
    |> Kernel.<>(IO.ANSI.cursor_up(@cursor_move))
    |> IO.puts()

    Process.sleep(speed)
  end

  defp to_print(number) do
    case Setting.get_setting("output") do
      {:ok, "text"} ->
        [to_string([number])]

      {:ok, "numbers"} ->
        [number]

      _ ->
        IO.inspect("Incorrect output type", syntax_colors: [string: :red])
        []
    end
  end
end
