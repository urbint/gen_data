defmodule GenData.SetTest do
  @moduledoc false

  use ExUnit.Case, async: true

  alias GenData.Set

  doctest Set

  Set.assert_impls!(Integer)
  Set.assert_impls!(Float)
  Set.assert_impls!(BitString)
end
