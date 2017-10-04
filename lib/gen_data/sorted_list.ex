defmodule GenData.SortedList do
  @moduledoc """
  A sequential data structure that remains sorted.

  Default sorting uses the `GenData.Comparable` instances of its members, or custom comparison can
  be specified.

  """

  alias GenData.{Macros, Comparable}
  require Macros

  Macros.require_impls [Comparable]



  ################################################################################
  # Types
  ################################################################################

  @type comparator :: ((any, any) -> boolean)

  @opaque t(contents) :: %__MODULE__{list: [contents], comparator: comparator}
  @type t :: t(any)

  defstruct [
    list: [],
    comparator: nil,
  ]



  ################################################################################
  # Public API
  ################################################################################

  @doc """
  Creates a sorted list from an enumerable.

  ## Examples

      iex> GenData.SortedList.new([1, 3, 2])
      #GenData.SortedList<[1, 2, 3]>

      iex> GenData.SortedList.new([1, 2, 3, 2])
      #GenData.SortedList<[1, 2, 2, 3]>

  """
  @spec new(Enumerable.t, options) :: t
    when options: [{:comparator, comparator}]
  def new(enumerable \\ [], options \\ []) do
    comparator =
      Keyword.get(options, :comparator, &Comparable.compare(&1, &2) == :lt)

    %__MODULE__{
      list: Enum.sort(enumerable, comparator),
      comparator: comparator,
    }
  end


  @doc """
  Add a new element to the given sorted list.

  ## Examples

    iex> list = GenData.SortedList.new([3, 4, 1])
    iex> GenData.SortedList.put(list, 2)
    #GenData.SortedList<[1, 2, 3, 4]>

  """
  @spec put(t, any) :: t
  def put(%__MODULE__{list: contents, comparator: comparator} = list, x) do
    %{list | list: Enum.sort([x | contents], comparator)}
  end


  defimpl Enumerable do
    def count(_), do: {:error, __MODULE__}

    def member?(_, _), do: {:error, __MODULE__}

    def reduce(%GenData.SortedList{list: list}, acc, reducer) do
      Enumerable.reduce(list, acc, reducer)
    end
  end


  defimpl Collectable do
    def into(original) do
      {original, fn
        list, {:cont, x} -> GenData.SortedList.put(list, x)
        list, :done      -> list
        _, :halt         -> :ok
      end}
    end
  end


  defimpl Inspect do
    import Inspect.Algebra

    def inspect(list, opts) do
      concat ["#GenData.SortedList<", to_doc(Enum.to_list(list), opts), ">"]
    end
  end
end
