defmodule Sequence do

  @enforce_keys [:state, :generator]
  defstruct(
    state: nil,
    generator: nil,
    first_state: nil,
    repeat_count: nil,
    limit_count: nil,
    other_seq_data: nil,
    limit: false,
    repeat: false,
    cycle: false,
    other_seq: false
  )

  def generate(%Sequence{generator: func, limit: true, limit_count: 0}) when is_function(func), do: nil
  def generate(%Sequence{state: nil, generator: func, limit: true}) when is_function(func), do: nil
  def generate(sequence = %Sequence{state: state, generator: func, limit: true, limit_count: n})
    when is_function(func) do
      {old_state, new_state} = func.(state)
      {old_state, %{sequence | state: new_state, limit_count: n - 1}}
  end
  def generate(%Sequence{state: nil, other_seq: true, other_seq_data: %{state: nil}}), do: nil
  def generate(sequence = %Sequence{state: nil, other_seq: true, other_seq_data: other_seq_data = %{state: state, generator: func}}) do
    {old_state, new_state} = func.(state)
    other_seq_data = %{other_seq_data | state: new_state}
    {old_state, %{sequence | other_seq_data: other_seq_data}}
  end
  def generate(sequence = %Sequence{state: state, generator: func, other_seq: true}) do
    {old_state, new_state} = func.(state)
    {old_state, %{sequence | state: new_state}}
  end
  def generate(sequence = %Sequence{state: nil, generator: func, cycle: true, first_state: first_state}) when is_function(func) do
    {old_state, new_state} = func.(first_state)
    {old_state, %{sequence | state: new_state}}
  end
  def generate(%Sequence{state: nil, generator: func, repeat: true, repeat_count: 0}) when is_function(func), do: nil
  def generate(sequence = %Sequence{state: nil, generator: func, repeat: true, repeat_count: n, first_state: first_state}) when is_function(func) do
    {old_state, new_state} = func.(first_state)
    {old_state, %{sequence | state: new_state, repeat_count: n - 1}}
  end
  def generate(%Sequence{state: nil, generator: func}) when is_function(func), do: nil
  def generate(sequence = %Sequence{state: state, generator: func}) when is_function(func) do
    {old_state, new_state} = func.(state)
    {old_state, %{sequence | state: new_state}}
  end

  def generate_next(sequence) do
    case generate(sequence) do
      nil ->
        nil
      {_old_state, sequence} ->
        sequence
    end
  end

  def generate_value(%Sequence{state: nil, generator: func}) when is_function(func), do: nil
  def generate_value(%Sequence{state: state, generator: func}) when is_function(func) do
    {element, _new_state} = func.(state)
    element
  end

  def advance(sequence, step) when is_number(step) and step >= 0, do: _advance_seq(sequence, step)

  def limit(sequence = %Sequence{state: nil, generator: func}, n)
    when is_function(func) and is_number(n) and n > 0, do: sequence
  def limit(sequence = %Sequence{generator: func}, n)
    when is_function(func) and is_number(n) and n > 0, do: %{sequence | limit: true, limit_count: n}

  def cycle(sequence = %Sequence{state: nil, generator: func})
    when is_function(func), do: clear_sequence(sequence)
  def cycle(sequence = %Sequence{state: state, generator: func})
    when is_function(func), do: %{clear_sequence(sequence) | cycle: true, first_state: state}

  def repeat(sequence = %Sequence{state: nil, generator: func}, n)
    when is_function(func) and is_number(n) and n >= 0, do: clear_sequence(sequence)
  def repeat(sequence = %Sequence{state: state, generator: func}, n)
    when is_function(func) and is_number(n) and n >= 0, do: %{clear_sequence(sequence) | first_state: state, repeat: true, repeat_count: n}

  def concatenate(sequence_one = %{generator: func1}, sequence_two = %{generator: func2})
    when is_function(func1) and is_function(func2) do
    sequence_one = clear_sequence(sequence_one)
    sequence_two = clear_sequence(sequence_two)
    %{sequence_one | other_seq: true, other_seq_data: sequence_two}
  end

  defp _advance_seq(sequence, 0), do: sequence
  defp _advance_seq(sequence, step) do
    case Sequence.generate(sequence) do
      nil ->
        _advance_seq(nil, 0)
      {_ele, sequence} ->
        _advance_seq(sequence, step - 1)
    end
  end

  defp clear_sequence(sequence) do
    %{sequence | limit: false, cycle: false, first_state: nil, repeat: false, other_seq: false, other_seq_data: nil, repeat_count: nil, limit_count: nil}
  end
end
