defmodule SequenceTest do
  use ExUnit.Case

  setup do
    endless_generator = &{&1, &1 + 1}
    end_generator = fn(state) ->
      case state do
        0 ->
          {state, 1}
        1 ->
          {state, 2}
        2 ->
          {state, nil}
      end
    end
    {:ok, %{endless: endless_generator, end: end_generator}}
  end

  test "generate a sequence if state is nil", %{endless: endless} do
    sequence = Sequence.generate(%Sequence{state: nil, generator: endless})
    assert sequence == nil
  end

  test "generate a sequence", %{endless: endless} do
    {old_state, sequence} = Sequence.generate(%Sequence{state: 0, generator: endless})
    assert old_state == 0 && sequence.state == 1 && sequence.generator == endless
  end

  test "generate a value if state is nil", %{endless: endless} do
    value = Sequence.generate_value(%Sequence{state: nil, generator: endless})
    assert value == nil
  end

  test "generate a value", %{endless: endless} do
    value = Sequence.generate_value(%Sequence{state: 0, generator: endless})
    assert value == 0
  end

  test "generate next if state is nil", %{endless: endless} do
    sequence = Sequence.generate_next(%Sequence{state: nil, generator: endless})
    assert sequence == nil
  end

  test "generate next state", %{endless: endless} do
    sequence = Sequence.generate_next(%Sequence{state: 0, generator: endless})
    assert sequence == %Sequence{state: 1, generator: endless}
  end

  test "advance sequence if state step given is 0", %{endless: endless} do
    sequence = Sequence.advance(%Sequence{state: nil, generator: endless}, 0)
    assert %Sequence{state: nil, generator: endless} == sequence
  end

  test "advance sequence if state is nil", %{endless: endless} do
    sequence = Sequence.advance(%Sequence{state: nil, generator: endless}, 20)
    assert sequence == nil
  end

  test "advance sequence if step is 0", %{endless: endless} do
    sequence = Sequence.advance(%Sequence{state: 0, generator: endless}, 0)
    assert sequence == %Sequence{state: 0, generator: endless}
  end

  test "advance sequence", %{endless: endless} do
    sequence = Sequence.advance(%Sequence{state: 0, generator: endless}, 5)
    assert sequence == %Sequence{state: 5, generator: endless}
  end

  test "limit", %{end: end_generator} do
    sequence = Sequence.limit(%Sequence{state: 0, generator: end_generator}, 2)
    {element, sequence} = Sequence.generate(sequence)
    {element, sequence} = Sequence.generate(sequence)
    assert Sequence.generate(sequence) == nil
  end


end
