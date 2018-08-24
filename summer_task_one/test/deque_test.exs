defmodule DequeTest do
  use ExUnit.Case, async: false

  test "update at front" do
    deque = %Deque{} |> Deque.push_front(1)
    [head | tail] = deque.front
    assert head = 1
  end

  test "multiple updates at front" do
    deque = %Deque{} |> Deque.push_front(1) |> Deque.push_front(2)
    [head | tail] = deque.front
    assert head = 2
  end

  test "update at back" do
    deque = %Deque{} |> Deque.push_back(1)
    [head | tail] = deque.back
    assert head = 1
  end

  test "multiple updates at back" do
    deque = %Deque{} |> Deque.push_back(1) |> Deque.push_back(2)
    [head | tail] = deque.back
    assert head = 2
  end

  test "pop back no elements" do
    deque = %Deque{} |> Deque.pop_back()
    assert deque == %Deque{}
  end

  test "pop back, but back list is empty and front has only one element" do
    deque = %Deque{} |> Deque.push_front(1) |> Deque.pop_back()
    assert deque == %Deque{}
  end

  test "pop back, but back list is empty and front has more than one element" do
    deque = %Deque{} |> Deque.push_front(1) |> Deque.push_front(2) |> Deque.pop_back()
    [head | _tail] = deque.back
    assert head == 2
  end

  test "pop back and back has one element" do
    deque = %Deque{} |> Deque.push_back(1) |> Deque.pop_back()
    assert deque == %Deque{}
  end

  test "pop back and back has more than one element" do
    deque = %Deque{} |> Deque.push_back(1) |> Deque.push_back(2) |> Deque.pop_back()
    [head | _tail] = deque.back
    assert head == 1
  end

  test "pop front no elements" do
    deque = %Deque{} |> Deque.pop_front()
    assert deque == %Deque{}
  end

  test "pop front, but front list is empty and back has only one element" do
    deque = %Deque{} |> Deque.push_back(1) |> Deque.pop_front()
    assert deque == %Deque{}
  end

  test "pop front, but front list is empty and back has more than one element" do
    deque = %Deque{} |> Deque.push_back(1) |> Deque.push_back(2) |> Deque.pop_front()
    [head | _tail] = deque.front
    assert head == 2
  end

  test "pop front and front has one element" do
    deque = %Deque{} |> Deque.push_front(1) |> Deque.pop_front()
    assert deque == %Deque{}
  end

  test "pop front and front has more than one element" do
    deque = %Deque{} |> Deque.push_front(1) |> Deque.push_front(2) |> Deque.pop_front()
    [head | _tail] = deque.front
    assert head == 1
  end

  test "get last element, but deque is empty" do
    last_element = %Deque{} |> Deque.last()
    assert last_element == nil
  end

  test "get last element, but only front list has elements" do
    last_element = %Deque{} |> Deque.push_front(1) |> Deque.push_front(2) |> Deque.last()
    assert last_element == 1
  end

  test "get last element, back list has elements" do
    last_element = %Deque{} |> Deque.push_front(1) |> Deque.push_back(2) |> Deque.last()
    assert last_element == 2
  end

  test "get front element, but deque is empty" do
    front_element = %Deque{} |> Deque.first()
    assert front_element == nil
  end

  test "get front element, but only back list has elements" do
    front_element = %Deque{} |> Deque.push_back(1) |> Deque.push_back(2) |> Deque.first()
    assert front_element == 1
  end

  test "get front element, front list has elements" do
    front_element = %Deque{} |> Deque.push_back(1) |> Deque.push_front(2) |> Deque.first()
    assert front_element == 2
  end

  test "access element when deque is empty" do
    deque = %Deque{} |> Deque.access_at(10)
    assert deque == nil
  end

  test "access element, but index is out of bounds" do
    deque1 = %Deque{} |> Deque.push_front(1) |> Deque.access_at(5)
    deque2 = %Deque{} |> Deque.push_back(1) |> Deque.access_at(5)
    deque3 = %Deque{} |> Deque.push_front(1) |> Deque.push_back(2) |> Deque.access_at(5)
    assert deque1 == nil && deque2 == nil && deque3 == nil
  end

  test "access element" do
    deque1 = %Deque{} |> Deque.push_front(2) |> Deque.push_front(1) |> Deque.push_back(3) |> Deque.push_back(4) |> Deque.access_at(0)
    assert deque1 == 1
  end

  test "assign when deque is empty" do
    deque = %Deque{} |> Deque.assign_at(2, 1)
    assert deque == nil
  end

  test "assign when index is out of bounds" do
    deque1 = %Deque{} |> Deque.push_front(1) |> Deque.assign_at(5, 2)
    deque2 = %Deque{} |> Deque.push_back(1) |> Deque.assign_at(5, 2)
    deque3 = %Deque{} |> Deque.push_front(1) |> Deque.push_back(2) |> Deque.assign_at(5, 2)
    assert deque1 == nil && deque2 == nil && deque3 == nil
  end

  test "assign element" do
    # [1, 2, 3, 4]
    deque1 = %Deque{front: [1, 2], back: [4, 3], size_front: 2, size_back: 2}
    # [1, 2, 3, 5, 6, 7, 8]
    deque2 = %Deque{front: [1, 2, 3], back: [8, 7, 6, 5], size_front: 3, size_back: 4}

    assigned_element1 = Deque.assign_at(deque1, 2, 5) |> Deque.access_at(2)
    assigned_element2 = Deque.assign_at(deque2, 6, 10) |> Deque.access_at(6)

    assert  assigned_element2 == 10
  end




end
