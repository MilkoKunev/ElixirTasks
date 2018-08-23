# Информация

Задачата е за промяна на точките от домашни в курса по Elixir, проведен през лятната сесия 2017/2018
Тя носи общо **15 точки**:
- 10 за имплементация
- 5 за тестове

Освен имплементацията на задачата, вие ще трябва да напишете и смислени тестове към нея.

По време на изпитването ще Ви бъдат задавани въпроси, свързани с имплементацията и познаването на езика. Неразбиране на написаният от Вас код ще доведе до отнемане на точки.

Задачата няма краен срок - тя ще бъде оценена на място при провеждането на поправителния изпит на **25.08.2018г.** от 13:00 в зала 305.

## Deque

Задачата е да направите структура, която реализира структурата от данни **Deque**.

Структурата трябва да е дефинирана в модул с името **Deque** (вече имате създаден такъв във файла `lib/deque.ex`). Всички функции за работа с нея трябва да се намират в същия модул.

### Какво представлява Deque

Декът е структура, подобна на динамичен масив, с малката разлика, че освен да добавяме елементи в края ѝ може да го правим и в началото на "масива". Друга характеристика е, че лесно можем да достъпваме и променяме елементите на дека, чрез техния индекс (индексацията на елементите в "дек" винаги започва от 0). Всички тези операции трябва да са сравнително "бързи" (да не отнемат линейно време) - ако не спазите това ограничение, най-вероятно няма да получите максималния брой точки.

### Как трябва да изглежда вашата имплементация

Структурата, която дефинирате, може да има каквито прецените полета, но трябва да можем да създаваме "дек", посредством **%Deque{}**. (В обяснението на функциите е дадена една примерна реализация за по-лесно илюстриране, тя обаче не е много добра, така че помислете за нещо по-добро)

### Какви функции трябва да има в модула Deque

Всички публични функции са описани в следващите параграфи. Вие можете да добавяте колкото искате не-експортирани функции (**defp**). Всяка публична функция от модула трябва да приема като първи аргумент инстанция на **Deque**.

#### Deque.new()

Аналогично на `%Deque{}` създава празден "дек". Например, ако разгледаме реализация на "дек", съдържаща едно поле (:content) в което държим списък.

```elixir
iex> %Deque{}
%Deque{content: []}
iex> Deque.new()
%Deque{content: []}
iex> %Deque{} == Deque.new()
true
```

#### Deque.size(deque)

Връща броя елементи съдържащи се в **deque**.

```elixir
iex> %Deque{content: [1, 2.0, "three"]} |> Deque.size
3
```

#### Deque.push_back(deque, element)

Връща нов "дек", подобен на **deque**, но с добавен последен елемент **element**.

```elixir
iex> %Deque{content: [1, 2.0, "three"]} |> Deque.push_back(:four)
%Deque{content: [1, 2.0, "three", :four]}
```

#### Deque.push_front(deque, element)

Връща нов "дек", подобен на **deque**, но с добавен първи елемент **element**.

```elixir
iex> %Deque{content: [1, 2.0, "three"]} |> Deque.push_front(:zero)
%Deque{content: [:zero, 1, 2.0, "three"]}
```

#### Deque.pop_back(deque)

Връща нов "дек", подобен на **deque**, но с премахнат последен елемент. Ако елементите на новия "дек" са 0, то да се върне `%Deque{}`. Ако **deque** няма елемент да се върне **deque**.

```elixir
iex> %Deque{content: [1, 2.0, "three"]} |> Deque.pop_back
%Deque{content: [1, 2.0]}
iex> %Deque{content: []} |> Deque.pop_back
%Deque{content: []}
iex> ( %Deque{content: [1]} |> Deque.pop_back ) == %Deque{}
true
```

#### Deque.pop_front(deque)

Връща нов "дек", подобен на **deque**, но с премахнат първи елемент. Ако елементите на новия "дек" са 0, то да се върне `%Deque{}`. Ако **deque** няма елемент да се върне **deque**.

```elixir
iex> %Deque{content: [1, 2.0, "three"]} |> Deque.pop_front
%Deque{content: [2.0, "three"]}
iex> %Deque{content: []} |> Deque.pop_front
%Deque{content: []}
iex> ( %Deque{content: [1]} |> Deque.pop_front ) == %Deque{}
true
```

#### Deque.last(deque)

Връша последния елемент в **deque**, ако "декът" е празен връща `nil`.

```elixir
iex> %Deque{content: [1, 2.0, "three"]} |> Deque.last
"three"
iex> Deque.new() |> Deque.last
nil
```

#### Deque.first(deque)

Връша първия елемент в **deque**, ако "декът" е празен връща `nil`.


```elixir
iex> %Deque{content: [1, 2.0, "three"]} |> Deque.first
1
iex> Deque.new() |> Deque.first
nil
```

#### Deque.access_at(deque, n)

Връща елемента на позиция **n** от **deque**. Ако "декът" няма позиция **n** функцията връща `nil`, а ако **n** не е цяло число се случва грешка (каквато и да е).

```elixir
iex> deque = %Deque{content: [1, 2.0, "three"]}
%Deque{content: [1, 2.0, "three"]}
iex> deque |> Deque.access_at(0)
1
iex> deque |> Deque.access_at(1)
2.0
iex> deque |> Deque.access_at(2)
"three"
iex> deque |> Deque.access_at(3)
nil
iex> Deque.access_at(deque, "2")
** (FunctionClauseError) no function clause matching in ...
```

#### Deque.assign_at(deque, n, element)

Връща нов "дек", подобен на **deque**, но елемента на позиция **n** е сменен с **element**. Ако няма елемент с индекс **n** или **n** не е цяло число се случва грешка (каквато и да е).


```elixir
iex> deque = %Deque{content: [1, 2.0, "three"]}
%Deque{content: [1, 2.0, "three"]}
iex> deque |> Deque.assign_at(0, :zero)
%Deque{content: [:zero, 2.0, "three"]}
iex> deque |> Deque.assign_at(1, :one)
%Deque{content: [1, :one, "three"]}
iex> deque |> Deque.assign_at(2, :two)
%Deque{content: [1, 2.0, :two]}
iex> deque |> Deque.assign_at(3)
** (FunctionClauseError) no function clause matching in ...
iex> deque |> Deque.assign_at("2")
** (FunctionClauseError) no function clause matching in ...
```

#### Имплементация на протоколи

За структурата **Deque** да се имплементират протоколите **Collectable** и **Enumerable**. За целта прочетете внимателно документацията на двата модула.

След като имплементирате **Collectable**, трябва да имате следното поведение за структурата ви:

```elixir
iex> deque = 0..5 |> Enum.into Deque.new
%Deque{content: [0, 1, 2, 3, 4, 5]}
iex> [:a, :b, :c] |> Enum.into deque
%Deque{content: [0, 1, 2, 3, 4, 5, :a, :b, :c]}
```

Протокола **Enumerable** трябва да ви позволи да подавате структурата, като първи аргумент на всички други функции от модула **Enum**:


```elixir
iex> deque = %Deque{content: [0, 1, 2, 3, 4, 5]}
%Deque{content: [0, 1, 2, 3, 4, 5]}
iex> deque |> Enum.take 2
[0, 1]
iex> deque |> Enum.drop 3
[3, 4, 5]
iex> deque |> Enum.map &(&1*&1)
[0, 1, 4, 9, 16, 25]
iex> deque |> Enum.reverse
[5, 4, 3, 2, 1, 0]
```
