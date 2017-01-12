defmodule GenData.Macros do
  @moduledoc false

  defmacro require_impls(impls) do
    quote do
      data_set_name =
        __MODULE__ |> Module.split |> List.last

      @doc """
      Asserts that all requisite implementations are implemented for a specific
      type.

      Useful for compile time enforcements to ensure that a type implements all requisite protocls
      to be used with the #{data_set_name}.

      """
      @spec assert_impls!(any) :: :ok | no_return
      def assert_impls!(type) do
        unquote(impls)
        |> Enum.each(&Protocol.assert_impl!(&1, type))
      end
    end
  end
end
