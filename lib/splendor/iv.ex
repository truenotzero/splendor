defmodule Splendor.Iv do
  @typedoc """
  4-byte Initialization Vector
  """
  @type t :: <<_::32>>

  @doc """
  Randomly generates a cryptographically strong IV
  """
  @spec gen_iv :: t()
  def gen_iv do
    :crypto.strong_rand_bytes(4)
  end

  def expand(iv) do
    :binary.copy(iv, 4)
  end
end
