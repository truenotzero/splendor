defmodule Splendor.Frontend.CustomOFBCipher do
  require Logger
  @moduledoc """
  Implements the game's custom AES-OFB cipher
  """

  @enforce_keys [:cipher, :iv]
  defstruct @enforce_keys

  @typedoc """
  Network cipher object
  """
  @type t :: %__MODULE__{cipher: :cipher.crypto_state(), iv: Splendor.Frontend.Iv.iv()}

  @spec init(Splendor.Frontend.Iv.t()) :: t()
  def init(iv) do
    import Splendor.Frontend.Util
    cfg = fetch_module_config!()
    cipher = :crypto.crypto_dyn_iv_init(:aes_256_cbc, cfg[:key] |> expand(), true)
    %__MODULE__{cipher: cipher, iv: iv}
  end

  defp expand(key) do
    for <<b <- key>>, into: <<>>, do: <<b, 0, 0, 0>>
  end

  defp crypt_ofb(data, t) do
    sz = byte_size(data) |> div(16)
    sz = 16 * (sz + 1)
    dummy_input = <<0>> |> :binary.copy(sz)
    :crypto.crypto_dyn_iv_update(t.cipher, dummy_input, t.iv |> Splendor.Frontend.Iv.expand())
      |> :binary.part({0, byte_size(data)})
      |> :crypto.exor(data)
  end

  @doc """
  Applies the custom cipher to a piece of data
  Note that encryption and decryption are the same operation, so this function does both
  """
  @spec crypt(binary(), t()) :: {binary(), t()}
  def crypt(data, t) do
    # TODO: long runs
    data = crypt_ofb(data, t)
    {data, %{t | iv: t.iv |> Splendor.Frontend.Iv.next()}}
  end
end
