defprotocol GenData.Comparable do
  @moduledoc """
  Protocol for comparing values as less than, equal to, or greater than other values.

  Custom types can define their own instances of `Comparable`, and then modules which use those
  custom types may import `GenData.Compare` to overload the comparison operators to use those
  `Comparable` instances.

  """


  @fallback_to_any true


  @doc """
  Compare this value with another value.

  Note the `any` on the right-hand side of the typespec; this function *must* compare with all
  elixir terms, not just terms of the same type.

  """
  @spec compare(t, any) :: :lt | :eq | :gt
  def compare(x, y)
end


defimpl GenData.Comparable, for: Any do
  def compare(x, y) do
    cond do
      x < y  -> :lt
      x == y -> :eq
      x > y  -> :gt
    end
  end
end
