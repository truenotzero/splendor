defmodule Splendor.Frontend.Cipher do
  @moduledoc """
  Ties all required cryptography components into one module for ease-of-use
  """

  @enforce_keys [:send, :recv, :version]
  defstruct @enforce_keys

  @typedoc """
  Cipher object for sending and receiving encrypted data
  """
  @type t :: %__MODULE__{send: Splendor.Frontend.CustomOFBCipher.t(), recv: Splendor.Frontend.CustomOFBCipher.t(), version: non_neg_integer()}

  @doc """
  Creates a new cipher object, with the possibility to introduce an already-existing IV
  """
  @spec new(non_neg_integer(), Splendor.Frontend.Iv.t(), Splendor.Frontend.Iv.t()) :: t()
  def new(game_version_major, send_iv \\ Splendor.Frontend.Iv.new(), recv_iv \\ Splendor.Frontend.Iv.new()) do
    send = send_iv |> Splendor.Frontend.CustomOFBCipher.init()
    recv = recv_iv |> Splendor.Frontend.CustomOFBCipher.init()
    %__MODULE__{send: send, recv: recv, version: game_version_major}
  end

  @doc """
  Encrypts a piece of outgoing data
  """
  @spec encrypt(binary(), t()) :: {binary(), t()}
  def encrypt(data, cipher) do
    header = data
      |> byte_size()
      |> Splendor.Frontend.Iv.create_header(cipher.send.iv, cipher.version)

    data = data |> Splendor.Frontend.RollCipher.encrypt()
    {data, send} = Splendor.Frontend.CustomOFBCipher.crypt(data, cipher.send)
    {header <> data, %{cipher | send: send}}
  end

  @doc """
  Forwards to `Splendor.Iv.validate_header/3`
  """
  @spec validate_header(<<_::32>>, t()) :: {:ok, non_neg_integer()} | {:error, :bad_header}
  def validate_header(header, cipher) do
    Splendor.Frontend.Iv.validate_header(header, cipher.recv.iv, cipher.version)
  end

  @doc """
  Decrypts a piece of incoming data
  """
  @spec decrypt(binary(), t()) :: {binary(), t()}
  def decrypt(data, cipher) do
    {data, recv} = Splendor.Frontend.CustomOFBCipher.crypt(data, cipher.recv)
    data = data |> Splendor.Frontend.RollCipher.decrypt()
    {data, %{cipher | recv: recv}}
  end
end
