defmodule Splendor.CustomOFBCipher do
  require Logger
  @moduledoc """
  Implements the game's custom AES-OFB cipher
  """

  @block_size 16

  @enforce_keys [:cipher, :iv]
  defstruct @enforce_keys

  @typedoc """
  Network cipher object
  """
  @type t :: %__MODULE__{cipher: :cipher.crypto_state(), iv: Splendor.Iv.iv()}

  @spec init(Splendor.Iv.t()) :: t()
  def init(iv) do
    import Splendor.Util
    cfg = fetch_module_config!()
    cipher = :crypto.crypto_dyn_iv_init(:aes_256_cbc, cfg[:key] |> expand(), true)
    %__MODULE__{cipher: cipher, iv: iv}
  end

  defp expand(key) do
    for <<b <- key>>, into: <<>>, do: <<b, 0, 0, 0>>
  end

  defp crypt_ofb(data, block_size, t) do
    dummy_input = <<0>> |> :binary.copy(@block_size)
    crypt = :crypto.crypto_dyn_iv_update(t.cipher, dummy_input, t.iv |> Splendor.Iv.expand())
      |> :binary.part({0, block_size})
      |> :crypto.exor(data)
    {:ok, crypt}
  end

  defp crypt_by_blocks(<<block::binary-size(@block_size), rest::binary>>, t) do
    {:ok, crypt} = crypt_ofb(block, @block_size, t)
    {:ok, rest} = crypt_by_blocks(rest, t)
    {:ok, crypt <> rest}
  end

  defp crypt_by_blocks(<<data::binary>>, t) do
    crypt_ofb(data, byte_size(data), t)
  end

  @doc """
  Applies the custom cipher to a piece of data
  Note that encryption and decryption are the same operation, so this function does both
  """
  @spec crypt(binary(), t()) :: binary()
  def crypt(data, t) do
    # TODO: long runs
    {:ok, result} = crypt_by_blocks(data, t)
    result
  end
end
