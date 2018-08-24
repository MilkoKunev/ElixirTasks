defmodule SequenceTest do
  use ExUnit.Case

  setup do
    infinite_generator = &{&1, &1 + 1}
    finite = fn(state) ->
      case state do
        0 ->
          {0, 1}
        1 ->
          {1, nil}
      end
    end
    {:ok, %{infinite: infinite_generator, finite: finite}}
  end

  test "generate a sequence if state is nil", %{infinite: infinite} do
    sequence = Sequence.generate(%Sequence{state: nil, generator: infinite})
    assert sequence == nil
  end

  test "generate a sequence", %{infinite: infinite} do
    {old_state, sequence} = Sequence.generate(%Sequence{state: 0, generator: infinite})
    assert old_state == 0 && sequence.state == 1 && sequence.generator == infinite
  end

  test "generate a value if state is nil", %{infinite: infinite} do
    value = Sequence.generate_value(%Sequence{state: nil, generator: infinite})
    assert value == nil
  end

  test "generate a value", %{infinite: infinite} do
    value = Sequence.generate_value(%Sequence{state: 0, generator: infinite})
    assert value == 0
  end

  test "generate next if state is nil", %{infinite: infinite} do
    sequence = Sequence.generate_next(%Sequence{state: nil, generator: infinite})
    assert sequence == nil
  end

  test "generate next state", %{infinite: infinite} do
    sequence = Sequence.generate_next(%Sequence{state: 0, generator: infinite})
    assert sequence == %Sequence{state: 1, generator: infinite}
  end

  test "advance sequence if state step given is 0", %{infinite: infinite} do
    sequence = Sequence.advance(%Sequence{state: nil, generator: infinite}, 0)
    assert %Sequence{state: nil, generator: infinite} == sequence
  end

  test "advance sequence if state is nil", %{infinite: infinite} do
    sequence = Sequence.advance(%Sequence{state: nil, generator: infinite}, 20)
    assert sequence == nil
  end

  test "advance sequence if step is 0", %{infinite: infinite} do
    sequence = Sequence.advance(%Sequence{state: 0, generator: infinite}, 0)
    assert sequence == %Sequence{state: 0, generator: infinite}
  end

  test "advance sequence", %{infinite: infinite} do
    sequence = Sequence.advance(%Sequence{state: 0, generator: infinite}, 5)
    assert sequence == %Sequence{state: 5, generator: infinite}
  end

  test "limit with finite sequence", %{finite: finite} do
    sequence = Sequence.limit(%Sequence{state: 0, generator: finite}, 2)
    {element, sequence} = Sequence.generate(sequence)
    {element, sequence} = Sequence.generate(sequence)
    assert Sequence.generate(sequence) == nil
  end

  test "limit with infinite sequence", %{infinite: infinite} do
    sequence = Sequence.limit(%Sequence{state: 0, generator: infinite}, 2)
    {element, sequence} = Sequence.generate(sequence)
    {element, sequence} = Sequence.generate(sequence)
    assert Sequence.generate(sequence) == nil
  end

  # Cycle tests
  test "test cycle, if given sequence has nil state", %{infinite: infinite} do
    sequence = Sequence.cycle(%Sequence{state: nil, generator: infinite})
    assert %Sequence{state: nil, generator: infinite} == sequence
  end

  test "test cycle, with finite sequence", %{finite: finite} do
    sequence =
      Sequence.cycle(%Sequence{state: 0, generator: finite})
    {_element, sequence} = Sequence.generate(sequence)
    {_element, sequence} = Sequence.generate(sequence)
    {element, sequence} = Sequence.generate(sequence)
    assert element == 0
  end

  test "test repeat with finite sequence when state is nil", %{finite: finite} do
    sequence = Sequence.repeat(%Sequence{state: nil, generator: finite}, 1)
    assert Sequence.generate(sequence) == nil
  end

  test "test repeat with finite sequence", %{finite: finite} do
    sequence = Sequence.repeat(%Sequence{state: 0, generator: finite}, 1)
    {_element, sequence} = Sequence.generate(sequence)
    {_element, sequence} = Sequence.generate(sequence)
    {_element, sequence} = Sequence.generate(sequence)
    {_element, sequence} = Sequence.generate(sequence)
    assert Sequence.generate(sequence) == nil
  end

  test "test concatenate if two sequences has state nil", %{finite: finite} do
    sequence_one = %Sequence{state: nil, generator: finite}
    sequence_two = %Sequence{state: nil, generator: finite}
    sequence = Sequence.concatenate(sequence_one, sequence_two)
    assert Sequence.generate(sequence) == nil
  end

  test "test concatenate only if first sequences has state, the other one has nil", %{finite: finite} do
    sequence_one = %Sequence{state: 0, generator: finite}
    sequence_two = %Sequence{state: nil, generator: finite}
    sequence = Sequence.concatenate(sequence_one, sequence_two)
    {_element, sequence} = Sequence.generate(sequence)
    {_element, sequence} = Sequence.generate(sequence)
    assert Sequence.generate(sequence) == nil
  end

  test "test concatentate when two lists have states", %{finite: finite} do
    sequence_one = %Sequence{state: 0, generator: finite}
    sequence_two = %Sequence{state: 0, generator: finite}
    sequence = Sequence.concatenate(sequence_one, sequence_two)
    {_element, sequence} = Sequence.generate(sequence)
    {_element, sequence} = Sequence.generate(sequence)
    {element1, sequence} = Sequence.generate(sequence)
    {element2, sequence} = Sequence.generate(sequence)
    assert element1 == 0 && element2 == 1 && Sequence.generate(sequence) == nil
  end



end
