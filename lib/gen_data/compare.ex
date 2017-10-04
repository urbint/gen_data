defmodule GenData.Compare do
  @moduledoc """
  `use GenData.Compare` to overload all comparison operators (`<=`, `>=`, `==`, `<`, `>`) in
  expressions to use `GenData.Comparable` instances for data

  """

  import Kernel, except: [<: 2, ==: 2, >: 2, <=: 2, >: 2]


  defmacro __using__(_) do
    quote do
      import Kernel, except: [<: 2, ==: 2, >: 2, <=: 2, >: 2]
      import GenData.Compare
    end
  end


  def x < y do
    GenData.Comparable.compare(x, y) == :lt
  end


  def x == y do
    GenData.Comparable.compare(x, y) == :eq
  end


  def x > y do
    GenData.Comparable.compare(x, y) == :gt
  end


  def x <= y do
    GenData.Comparable.compare(x, y) in [:eq, :lt]
  end


  def x >= y do
    GenData.Comparable.compare(x, y) in [:eq, :gt]
  end
end
