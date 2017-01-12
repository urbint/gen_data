defmodule DifferentOptionsError do
  defexception opts1: nil, opts2: nil

  def message(%{opts1: opts1, opts2: opts2}) do
    """
    options inconsistent between data structures.

      opts1: #{inspect opts1}

      opts2: #{inspect opts2}
    """
  end
end
