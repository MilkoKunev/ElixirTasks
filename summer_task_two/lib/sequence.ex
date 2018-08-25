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
  def generate(sequence = %Sequence{state: nil, generator: func1, limit: true, other_seq: true, limit_count: n, other_seq_data: other_seq_data = %{state: state, generator: func2}}) when is_function(func1) do
    {old_state, new_state} = func2.(state)
    {old_state, %{sequence | limit_counts: n - 1, other_seq_data: %{other_seq_data | state: new_state}}}
  end
  def generate(%Sequence{state: nil, generator: func1, limit: true, other_seq: true, other_seq_data: %{state: nil}}) when is_function(func1), do: nil
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

  defimpl Enumerable do
    def count(sequence) do
      {:ok, _count(sequence, 0)}
    end

    def member?(sequence, element) do
      {:ok, _member?(sequence, element, false)}
    end

    def reduce(_sequence, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(sequence, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(sequence, &1, fun)}
    def reduce(%Sequence{limit: true, limit_count: 0}, {:cont, acc}, _fun), do: {:done, acc}
    def reduce(%Sequence{state: nil, repeat: true, repeat_count: 0}, {:cont, acc}, _fun), do: {:done, acc}
    def reduce(%Sequence{state: nil, other_seq: true, other_seq_data: %{state: nil}}, {:cont, acc}, _fun), do: {:done, acc}
    def reduce(sequence, {:cont, acc}, fun) do
      {old_element, sequence} = Sequence.generate(sequence)
      reduce(sequence, fun.(old_element, acc), fun)
    end

    defp _count(%Sequence{limit: true, limit_count: n}, _size), do: n
    defp _count(%Sequence{state: nil, repeat: true, repeat_count: n}, size), do: n * size
    defp _count(%Sequence{state: nil, other_seq: true, other_seq_data: %{state: nil}}, size), do: size
    defp _count(%Sequence{state: nil}, size), do: size
    defp _count(sequence, size), do: _count(Sequence.generate_next(sequence), size + 1)

    defp _member?(%Sequence{state: nil}, _element, member?), do: member?
    defp _member?(_seq, _element, true), do: true
    defp _member?(sequence, element, _member?) do
      {generated_element, sequence} = Sequence.generate(sequence)
      _member?(sequence, element, element == generated_element)
    end
  end
end
