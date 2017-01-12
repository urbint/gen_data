defprotocol GenData.Hashable do
  @moduledoc """
  Protocol indicating that a term can be hashed.

  """

  @type t :: any

  @doc """
  Computes the hash for the provided value

  Takes an optional array of options which can be specified during
  the call to `new` for data strucutres.

  """
  def compute_hash(t, opts \\ [])
end

defimpl GenData.Hashable, for: [Integer,Float,BitString,Atom] do
  def compute_hash(num, _opts), do: num
end
