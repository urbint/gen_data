defmodule GenData.Set do
  @moduledoc """
  A module for working with sets.

  The `Set` is represented internally as a struct.


  """

  alias GenData.{Set,Hashable,Macros}
  require Macros

  Macros.require_impls [Hashable]


  @opaque t(value) :: %__MODULE__{map: %{term => value, opts: opts}}
  @type t :: t(term)

  @type value :: Hashable.t
  @type opts :: Keyword.t

  defstruct [map: %{}, opts: []]

  @doc """
  Returns a new set.

  ## Examples

      iex> GenData.Set.new
      #GenData.Set<[]>

  """
  @spec new :: t
  def new, do: %Set{}

  @doc """
  Returns a new set from an enumerable.

  ## Examples

      iex> GenData.Set.new([1, 2, 3, 3])
      #GenData.Set<[1, 2, 3]>

  """
  @spec new(Enum.t) :: t
  def new(enumerable) do
    enumerable
    |> Enum.reduce(new(), &put(&2, &1))
  end

  @doc """
  Returns a new set from an enumerable with the specified `opts`.

  The `opts` will be passed along to the `Hashable` implementations

  ## Examples

      iex> GenData.Set.new([1, 2, 3, 3])
      #GenData.Set<[1, 2, 3]>

  """
  @spec new(Enum.t, opts) :: t
  def new(enumerable, opts) do

    set =
      %{new() | opts: opts}

    enumerable
    |> Enum.reduce(set, &put(&2, &1))
  end



  @doc """
  Returns a new set which is a copy of `set` but without `value`.

  `opts` will be forwarded to the `Hashable` implementation.

  ## Examples

      iex> set = GenData.Set.new([1, 2, 3])
      iex> GenData.Set.delete(set, 2)
      #GenData.Set<[1, 3]>

  """
  @spec delete(t, value) :: t
  def delete(%Set{map: map, opts: opts} = set, value) do
    hash =
      Hashable.compute_hash(value, opts)

    %{set | map: Map.delete(map, hash)}
  end

  @doc """
  Returns a set that is `set` without the members of `set2`.

  `opts` will be forwarded to the `Hashable` implementation.

  ## Examples

      iex> set = GenData.Set.new([1, 3])
      iex> set2 = GenData.Set.new([3, 4])
      iex> GenData.Set.difference(set, set2)
      #GenData.Set<[1]>

  """
  @spec difference(t, t) :: t
  # If the first set is less than twice the size of the second map,
  # it is fastest to re-accumulate items in the first set that are not
  # present in the second set.
  def difference(%Set{}= set1, %Set{} = set2) do
    enforce_same_options!(set1, set2)

    do_difference(set1, set2)
  end

  defp do_difference(%Set{map: map1}, %Set{map: map2})
  when map_size(map1) < map_size(map2) * 2 do
    map = map1
    |> :maps.to_list
    |> filter_not_in(map2)

    %Set{map: map}
  end

  defp do_difference(%Set{map: map1}, %Set{map: map2}) do
    map =
      Map.drop(map1, Map.keys(map2))

    %Set{map: map}
  end

  defp filter_not_in(keys, map2, acc \\ [])
  defp filter_not_in([], _map2, acc), do: :maps.from_list(acc)
  defp filter_not_in([{key, val} | rest], map2, acc) do
    acc =
      if Map.has_key?(map2, key) do
        acc
      else
        [{key, val} | acc]
      end

    filter_not_in(rest, map2, acc)
  end

  @doc """
  Checks if `set` and `set2` have no members in common.

  ## Examples

      iex> alias GenData.Set
      ...> Set.disjoint?(Set.new([1, 2]), Set.new([3, 4]))
      true

      iex> Set.disjoint?(Set.new([1, 2]), Set.new([2, 3]))
      false

  """
  def disjoint?(%Set{map: map1} = set1, %Set{map: map2} = set2) do
    enforce_same_options!(set1, set2)

    {map1, map2} =
      order_by_size(map1, map2)

    map1
    |> Map.keys
    |> none_in?(map2)
  end

  defp none_in?([], _), do: true
  defp none_in?([key|rest], map2) do
    if Map.has_key?(map2, key) do
      false
    else
      none_in?(rest, map2)
    end
  end

  @doc """
  Checks if two sets are equal.

  The comparison between elements is done as a result of the `Hashable.t` value

  iex> alias GenData.Set
  ...> Set.equal?(Set.new([1, 2]), Set.new([1, 2]))
  true

  iex> Set.equal?(Set.new([1, 2]), Set.new([1]))
  false

  """
  @spec equal?(t, t) :: boolean
  def equal?(%Set{map: map1} = set1, %Set{map: map2} = set2) do
    enforce_same_options!(set1, set2)

    if map_size(map1) != map_size(map2) do
      false
    else
      Map.keys(map1) == Map.keys(map2)
    end
  end

  @doc """
  Checks if `set1`'s members are all contained in `set2`.

  ## Examples

  iex> alias GenData.Set
  ...> Set.subset?(Set.new([1, 2]), Set.new([1, 2, 3]))
  true

  iex> Set.subset?(Set.new([1, 3]), Set.new([1, 2, 4]))
  false

  """
  @spec subset?(t, t) :: boolean
  def subset?(%Set{map: map1} = set1, %Set{map: map2} = set2) do
    enforce_same_options!(set1, set2)

    if map_size(map1) <= map_size(map2) do
      map1
      |> Map.keys
      |> do_subset?(map2)
    else
      false
    end
  end

  def do_subset?([], _), do: true
  def do_subset?([key | rest], map2) do
    if Map.has_key?(map2, key) do
      do_subset?(rest, map2)
    else
      false
    end
  end


  @doc """
  Returns whether `set` contains `value`.

  ## Examples

    iex> GenData.Set.member?(GenData.Set.new([1, 2, 3]), 3)
    true

    iex> GenData.Set.member?(GenData.Set.new([1, 2, 3]), 4)
    false

  """
  @spec member?(t, value) :: boolean
  def member?(%Set{map: map, opts: opts}, value) do
    key =
      Hashable.compute_hash(value, opts)

    Map.has_key?(map, key)
  end


  @doc """
  Returns the number of elements in `set`.

  ## Examples

    iex> GenData.Set.size(GenData.Set.new([1, 2, 3]))
    3

  """
  @spec size(t) :: non_neg_integer
  def size(%Set{map: map}) do
    map_size(map)
  end


  @doc """
  Inserts `value` into `set` if `set` doesn't already contain it.

  ## Examples

      iex> GenData.Set.put(GenData.Set.new([1, 2, 3]), 3)
      #GenData.Set<[1, 2, 3]>

  """
  @spec put(t(val1), val2) :: t(val1 | val2) when val1: value, val2: value
  def put(%Set{map: map, opts: opts} = set, value) do
    hash =
      Hashable.compute_hash(value, opts)

    if Map.has_key?(map, hash) do
      set
    else
      %{set | map: Map.put(map, hash, value)}
    end
  end

  @doc """
  Returns a set containing all members of `set` and `set2`.

  ## Examples

      iex> alias GenData.Set
      ...> Set.union(Set.new([1, 2]), Set.new([2, 3, 4]))
      #GenData.Set<[1, 2, 3, 4]>

  """
  @spec union(t(val1), t(val2)) :: t(val1 | val2) when val1: value, val2: value
  def union(%Set{map: map1} = set1, %Set{map: map2} = set2) do
    enforce_same_options!(set1, set2)

    %Set{map: Map.merge(map1, map2)}
  end

  @doc """
  Returns a set containing only members that set1 and set2 have in common.

  ## Examples

      iex> alias GenData.Set
      ...> Set.intersection(Set.new([1, 2]), Set.new([2, 3]))
      #GenData.Set<[2]>

  """
  @spec intersection(t(val), t(val)) :: t(val) when val: value
  def intersection(%Set{map: map1} = set1, %Set{map: map2} = set2) do
    enforce_same_options!(set1, set2)

    {map1, map2} =
      order_by_size(map1, map2)

    %Set{map: Map.take(map2, Map.keys(map1))}
  end

  @doc """
  Converts `set` to a list.

  ## Example

      iex> GenData.Set.to_list(GenData.Set.new([1, 2, 3]))
      [1, 2, 3]

  """
  @spec to_list(t) :: list
  def to_list(%Set{map: map}) do
    Map.values(map)
  end

  defp order_by_size(map1, map2) when map_size(map1) > map_size(map2), do:
    {map2, map1}
  defp order_by_size(map1, map2), do:
    {map1, map2}

  defp enforce_same_options!(%Set{opts: opts1}, %Set{opts: opts2}) do
    unless Keyword.equal?(opts1, opts2) do
      raise(DifferentOptionsError, opts1: opts1, opts2: opts2)
    end
  end


  defimpl Inspect do
    import Inspect.Algebra

    def inspect(set, opts) do
      concat ["#GenData.Set<", Inspect.List.inspect(Set.to_list(set), opts), ">"]
    end
  end

  defimpl Collectable do
    def into(original) do
      {original, fn
        set, {:cont, x} ->
          Set.put(set, x)

        set, :done ->
          set

        _, :halt ->
          :ok
      end}
    end
  end

  defimpl Enumerable do
    def count(set), do: {:ok, Set.size(set)}
    def member?(set, val), do: {:ok, Set.member?(set, val)}
    def reduce(set, acc, fun), do:
      Enumerable.List.reduce(Set.to_list(set), acc, fun)
  end
end

