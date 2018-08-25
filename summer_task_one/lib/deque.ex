defmodule Deque do
  defstruct front: [], back: [], size_front: 0, size_back: 0

  def new() do
    %Deque{}
  end

  def size(%Deque{front: [] , back: []}), do: 0
  def size(%Deque{front: front, back: []}), do: length(front)
  def size(%Deque{front: front, back: back}), do: length(front) + length(back)

  def push_back(deque = %Deque{front: _front, back: back, size_back: size}, element), do: %{deque | back: [element | back], size_back: size + 1}

  def push_front(deque = %Deque{front: front, back: _back, size_front: size}, element), do: %{deque | front: [element | front], size_front: size + 1}

  def pop_back(deque = %Deque{front: [], back: []}), do: deque
  def pop_back(deque = %Deque{front: front, back: [], size_front: size}), do: remove_back_element(front, deque, size)
  def pop_back(deque = %Deque{front: _front, back: [_head | tail], size_back: size}), do: %{deque | back: tail, size_back: size - 1}

  def pop_front(deque = %Deque{front: [], back: []}), do: deque
  def pop_front(deque = %Deque{front: [], back: back, size_back: size}), do: remove_front_element(back, deque, size)
  def pop_front(deque = %Deque{front: [_head | tail], back: _back, size_front: size}), do: %{deque | front: tail, size_front: size - 1}

  def last(%Deque{front: [], back: []}), do: nil
  def last(%Deque{front: front, back: []}), do: get_element(front)
  def last(%Deque{front: _front, back: [head | _tail]}), do: head

  def first(%Deque{front: [], back: []}), do: nil
  def first(%Deque{front: [], back: back}), do: get_element(back)
  def first(%Deque{front: [head | _tail], back: _back}), do: head

  def access_at(%Deque{front: [], back: []}, index) when is_number(index), do: nil
  def access_at(%Deque{front: _front, back: [], size_front: size}, index) when is_number(index) and size - 1 < index, do: nil
  def access_at(%Deque{front: [], back: _back, size_back: size}, index) when is_number(index) and size - 1 < index, do: nil
  def access_at(%Deque{front: _front, back: _back, size_front: size_front, size_back: size_back}, index) when is_number(index) and (size_front + size_back - 1) < index, do: nil
  def access_at(%Deque{front: front, back: back}, index) when is_number(index), do: get_element_at(front ++ Enum.reverse(back), index)

  def assign_at(%Deque{front: [], back: []}, index, _element) when is_number(index), do: nil
  def assign_at(%Deque{back: [], size_front: size}, index, _element) when is_number(index) and size - 1 < index, do: nil
  def assign_at(%Deque{front: [], size_back: size}, index, _element) when is_number(index) and size - 1 < index, do: nil
  def assign_at(%Deque{size_back: size_back, size_front: size_front}, index, _element) when is_number(index) and (size_front + size_back - 1) < index, do: nil
  def assign_at(deque = %Deque{front: front, back: back, size_front: size_front, size_back: size_back}, index, element) when is_number(index) do
    cond do
      index <= size_front - 1 ->
        front = assign_element_at_front(front, index, element, [])
        %{deque | front: front}
      index > size_front - 1 ->
        back = assign_element_at_back(back, abs(index - size_front - (size_back - 1)), element, [])
        %{deque | back: back}
    end
  end
  def to_list(%Deque{front: front, back: back}), do: front ++ Enum.reverse(back)

  defp remove_back_element(_list, _deque, size) when size - 1 == 0, do: %Deque{}
  defp remove_back_element(list, deque, _size) do
    [_head | tail] = Enum.reverse(list)
    %{deque | front: [], back: tail}
  end

  defp remove_front_element(_list, _deque, size) when size - 1 == 0, do: %Deque{}
  defp remove_front_element(list, deque, _size) do
    [_head | tail] = Enum.reverse(list)
    %{deque | back: [], front: tail}
  end

  defp get_element([head | tail]) when length(tail) == 0, do: head
  defp get_element([_head | tail]), do: get_element(tail)

  defp get_element_at([head | _tail], 0), do: head
  defp get_element_at([_head | tail], index), do: get_element_at(tail, index - 1)

  defp assign_element_at_front([_head | tail], 0, element, acc), do: [element | tail] ++ Enum.reverse(acc)
  defp assign_element_at_front([head | tail], index, element, acc), do: assign_element_at_front(tail, index - 1, element, [head | acc])

  defp assign_element_at_back([_head | tail], 0, element, acc), do: Enum.reverse(acc) ++ [element | tail]
  defp assign_element_at_back([head | tail], index, element, acc), do: assign_element_at_back(tail, index - 1, element, [head | acc])

  defimpl Enumerable do
    def count(%Deque{size_front: size_front, size_back: size_back}) do
      {:ok, size_front + size_back}
    end

    def member?(%Deque{front: [], back: []}, _element), do:  {:ok, false}
    def member?(%Deque{front: [], back: back}, element), do: {:ok, Enum.member?(back, element)}
    def member?(%Deque{front: front, back: []}, element), do: {:ok, Enum.member?(front, element)}
    def member?(%Deque{front: front, back: back}, element), do: {:ok, Enum.member?(front, element) || Enum.member?(back, element)}

    def reduce(_deque, {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(deque, {:suspended, acc}, fun), do: {:suspend, acc, &reduce(deque, &1, fun)}
    def reduce(%Deque{front: [], back: []}, {:cont, acc}, _fun), do: {:done, acc}
    def reduce(%Deque{front: [head | tail], back: []}, {:cont, acc}, fun), do: reduce(%Deque{front: tail}, fun.(head, acc), fun)
    def reduce(%Deque{front: [], back: [head | tail]}, {:cont, acc}, fun), do: reduce(%Deque{back: tail}, fun.(head, acc), fun)
    def reduce(%Deque{front: [head | tail]}, {:cont, acc}, fun), do: reduce(%Deque{front: tail}, fun.(head, acc), fun)

    # TODO: add slice
  end

  defimpl Collectable do
    def into(original) do
      {original, fn
        (deque, {:cont, elem}) -> Deque.push_front(deque, elem)
        (deque, :done) -> deque
        (_set, :halt) -> :ok
      end}
    end
  end


end
