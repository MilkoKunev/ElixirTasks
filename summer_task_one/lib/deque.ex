defmodule Deque do
  defstruct front: [], back: []

  def new() do
    %Deque{}
  end

  def size(%Deque{front: [] , back: []}), do: 0
  def size(%Deque{front: front, back: []}), do: length(front)
  def size(%Deque{front: front, back: back}), do: length(front) + length(back)

  def push_back(deque = %Deque{front: _front, back: back}, element), do: %{deque | back: [element | back]}

  def push_front(deque = %Deque{front: front, back: _back}, element), do: %{deque | front: [element | front]}

  def pop_back(deque = %Deque{front: [], back: []}), do: deque
  def pop_back(deque = %Deque{front: front, back: []}), do: remove_last_element(front, deque)
  def pop_back(deque = %Deque{front: _front, back: [_head | tail]}), do: %{deque | back: tail}

  def pop_front(deque = %Deque{front: [], back: []}), do: deque
  def pop_front(deque = %Deque{front: [], back: back}), do: remove_front_element(back, deque)
  def pop_front(deque = %Deque{front: [_head | tail], back: _back}), do: %{deque | front: tail}

  def last(%Deque{front: [], back: []}), do: nil
  def last(%Deque{front: front, back: []}), do: get_element(front)
  def last(%Deque{front: _front, back: [head | _tail]}), do: head

  def first(%Deque{front: [], back: []}), do: nil
  def first(%Deque{front: [], back: back}), do: get_element(back)
  def first(%Deque{front: [head | _tail], back: _back}), do: head

  def access_at(%Deque{front: [], back: []}, index) when is_number(index), do: nil
  def access_at(%Deque{front: front, back: []}, index) when is_number(index) and length(front) - 1 < index, do: nil
  def access_at(%Deque{front: [], back: back}, index) when is_number(index) and length(back) - 1 < index, do: nil
  def access_at(%Deque{front: front, back: back}, index) when is_number(index) and (length(front) + length(back) - 1) < index, do: nil
  def access_at(%Deque{front: front, back: back}, index) when is_number(index), do: get_element_at(front ++ Enum.reverse(back), index)

  def assign_at(%Deque{front: [], back: []}, index, _element) when is_number(index), do: nil
  def assign_at(%Deque{front: front, back: []}, index, _element) when is_number(index) and length(front) - 1 < index, do: nil
  def assign_at(%Deque{front: [], back: back}, index, _element) when is_number(index) and length(back) - 1 < index, do: nil
  def assign_at(%Deque{front: front, back: back}, index, _element) when is_number(index) and (length(front) + length(back) - 1) < index, do: nil
  def assign_at(deque = %Deque{front: front, back: back}, index, element) when is_number(index) do
    cond do
      index <= length(front) - 1 ->
        front = assign_element_at_front(front, index, element, [])
        %{deque | front: front}
      index > length(front) - 1 ->
        back = assign_element_at_back(back, abs(index - length(front) - (length(back) - 1)), element, [])
        %{deque | back: back}
    end
  end
  def to_list(%Deque{front: front, back: back}), do: front ++ Enum.reverse(back)

  defp remove_last_element([_head | tail], _deque) when length(tail) == 0, do: %Deque{}
  defp remove_last_element(list, deque) do
    [_head | tail] = Enum.reverse(list)
    %{deque | front: [], back: tail}
  end

  defp remove_front_element([_head | tail], _deque) when length(tail) == 0, do: %Deque{}
  defp remove_front_element(list, deque) do
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

end
