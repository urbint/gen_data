defmodule GenData.SortedListTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias GenData.SortedList
  doctest SortedList

  property "`Enum.into` is the same as `new/1`" do
    check all list <- list_of(integer()) do
      assert SortedList.new(list) == Enum.into(list, SortedList.new())
    end
  end

  property "Enumeration is always in order" do
    check all list <- list_of(integer()) do
      sorted =
        SortedList.new(list)

      assert Enum.sort(list) == Enum.to_list(sorted)
    end
  end
end
