defmodule Splendor.PacketBuffer do
  @moduledoc """
  A utility module for serializing and deserializing packets

  TODO: deserialization
  """


  @type short :: 0..0xFFFF
  @type int :: 0..0xFFFF_FFFF
  @type long :: 0..0xFFFF_FFFF_FFFF_FFFF
  @type t :: binary()

  @spec push8(t(), byte()) :: t()
  def push8(buffer, n) do
    buffer <> <<n::8>>
  end

  @spec push16(t(), short()) :: t()
  def push16(buffer, n) do
    buffer <> <<n::16-little>>
  end

  @spec push32(t(), int()) :: t()
  def push32(buffer, n) do
    buffer <> <<n::32-little>>
  end

  @spec push64(t(), long()) :: t()
  def push64(buffer, n) do
    buffer <> <<n::64-little>>
  end

  @spec pushstr(t(), String.t()) :: t()
  def pushstr(buffer, str) do
    push16(buffer, byte_size(str)) <> str
  end

  @doc """
  Finalizes the buffer for sending over the wire
  """
  @spec finalize(t()) :: t()
  def finalize(buffer) do
    <<byte_size(buffer)::16-little>> <> buffer
  end
end
