defmodule Splendor.Cipher do
  @moduledoc """
  Ties all required cryptography components into one module for ease-of-use
  """

  @enforce_keys [:send, :recv]
  defstruct @enforce_keys

  @typedoc """
  Cipher object for sending and receiving encrypted data
  """
  @type t :: %__MODULE__{send: Splendor.CustomOFBCipher.t(), recv: Splendor.CustomOFBCipher.t()}

  @doc """
  Creates a new cipher object, with the possibility to introduce an already-existing IV
  """
  @spec new(Splendor.Iv.t(), Splendor.Iv.t()) :: t()
  def new(send_iv \\ Splendor.Iv.new(), recv_iv \\ Splendor.Iv.new()) do
    send = send_iv |> Splendor.CustomOFBCipher.init()
    recv = recv_iv |> Splendor.CustomOFBCipher.init()
    %__MODULE__{send: send, recv: recv}
  end

  @doc """
  Encrypts a piece of outgoing data
  """
  @spec encrypt(binary(), t()) :: binary()
  def encrypt(data, t) do
    data |> Splendor.RollCipher.encrypt() |> Splendor.CustomOFBCipher.crypt(t.send)
  end

  @doc """
  Decrypts a piece of incoming data
  """
  @spec decrypt(binary(), t()) :: binary()
  def decrypt(data, t) do
    data |> Splendor.CustomOFBCipher.crypt(t.recv) |> Splendor.RollCipher.decrypt()
  end
end
